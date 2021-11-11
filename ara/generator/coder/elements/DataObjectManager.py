from .SourceElement import Block, Statement, ForRange
from collections import namedtuple

class UnderscorifyMap:
    def __getitem__(self, key):
        if chr(key).isalnum():
            return key
        return '_'

class DataObject:
    """Manages a variable"""

    def __init__(self, typename, name,
                 static_initializer = None,
                 dynamic_initializer = False,
                 do_cast = False,
                 attributes = None,
                 extern_c = False, alignment=None):
        self.typename = typename
        self.name = name.translate(UnderscorifyMap())
        self.__static_initializer = static_initializer
        self.dynamic_initializer = dynamic_initializer
        self.data_object_manager = None
        self.phase = 0
        self.extern_c = extern_c
        self.declaration_prefix = ""
        self.allocation_prefix = ""
        self.alignment = alignment
        self.container = ""
        self.do_cast = do_cast
        self.attributes = attributes

    def generate_prefix(self):
        prefix = "extern "
        if self.extern_c:
            prefix += '"C" '
        if self.alignment:
            prefix += "__attribute__((aligned(%s))) " % self.alignment
        if self.attributes:
            for attribute in self.attributes:
                prefix += f'__attribute__(({attribute})) '
        return self.declaration_prefix + prefix

    def source_element_declaration(self):
        """Builds an extern declaration of the data object"""

        return Statement(self.generate_prefix() + self.typename + " " + self.name)

    def source_element_allocation(self):
        """Builds an allocation statement for the object.

            If a static_initializer is set, the object
            is initialized accordingly.

            Example: typename = 'int', name = 'x', static_initializer = 23
            emits:

                int x = 23;

            @return A Statement comprising the C allocation code
        """
        if self.static_initializer() != None and self.static_initializer()[0] != "(":
            return Statement(self.allocation_prefix
                             + self.typename + " "
                             + self.name + " = "
                             + self.typecast
                             + str(self.static_initializer()))
        if self.static_initializer() != None and self.static_initializer()[0] == "(":
            return Statement(self.allocation_prefix
                             + self.typename + " "
                             + self.name
                             + str(self.static_initializer()))
        return Statement(self.allocation_prefix + self.typename + " " + self.name)

    def static_initializer(self, indent=0):
        ret = self.__static_initializer
        if callable(ret):
            ret = ret()
        return ret

    @property
    def typecast(self):
        if not self.do_cast:
            return ''
        if not self.typename:
            return ''
        return f"({self.typename}) "

    @property
    def value(self):
        return self.__static_initializer

    @property
    def address(self):
        return '&' + self.lvalue()

    def lvalue(self, child=None):
        return self.container.lvalue(self) if self.container else self.name

    def source_element_initializer(self):
        """Builds a dynamic initialization statement.

            :returns: A Statement invoking the init() method of the object
        """
        if self.dynamic_initializer:
            return Statement(self.data_object_manager.get_namespace() + "::" + self.name + ".init()")
        return []

    def __str__(self):
        return f"<{self.typename} {self.name} {self.__static_initializer}>"

class ExternalDataObject(DataObject):
    """Manages an external declaration"""

    def __init__(self, typename, name, **kwargs):
        DataObject.__init__(self, typename, name, **kwargs)

    def source_element_allocation(self):
        return ""

    def source_element_allocation(self):
        return ""

class DataObjectArray(DataObject):
    def __init__(self, typename, name, elements, dynamic_initializer = False, extern_c = False, alignment=None):
        DataObject.__init__(self, typename, name, None, dynamic_initializer,
                            extern_c, alignment)
        self.elements = elements
        self.__element_values = {}

    def source_element_declaration(self):
        return Statement(f"{self.generate_prefix()}{self.typename} "
                         f"{self.name}[{self.elements}]")

    def source_element_initializer(self):
        if self.dynamic_initializer:
            loop = ForRange(0, self.elements)
            loop.add(Statement("%s::%s[%s].init()"%(self.data_object_manager.get_namespace(),
                                                   self.name, loop.get_counter())))
            return loop
        return []

    def source_element_allocation(self, indent=0):
        init = " = " + self.static_initializer()
        return Statement(f"{self.allocation_prefix}{self.typename} "
                         f"{self.name}[{self.elements}]{init}")

    def __setitem__(self, key, item):
        if not isinstance(key, int):
            raise ValueError("Key must be int not ", type(key))
        if not isinstance(item, DataObject):
            item = DataObject(self.typename, str(key), item)
        item.name = key
        item.container = self
        self.__element_values[key] = item

    def __getitem__(self, key):
        return self.__element_values[key]

    def static_initializer(self, indent=2):
        ret = [self.__element_values[key].static_initializer(indent=indent+2)
               for key in range(max(self.__element_values.keys(), default=-1)+1)]
        return "{ " +", ".join(ret) + "}"

    def lvalue(self, child=None):
        lv = self.container.lvalue(self) if self.container else self.name
        if child is not None:
            lv += f'[{child.name}]'
        return lv


class StructDataObject(DataObject):
    def __init__(self, typename, name,
                 **kwargs):
        DataObject.__init__(self, typename, name, **kwargs)
        self.__entries = {}

    def __getitem__(self, key):
        if key not in self.__entries:
            self.__entries[key] = DataObject('', key)
        return self.__entries[key]

    def __setitem__(self, key, value):
        if isinstance(value, DataObject):
            if key != value.name:
                raise ValueError("Name and Key do not match", key, value.name)
        else:
            tn = self.__entries[key].typename if key in self.__entries else ''
            value = DataObject(tn, key, value)
        value.container = self
        self.__entries[key] = value

    def static_initializer(self, indent=2):
        ret = [f".{k} = {v.typecast}{v.static_initializer(indent+2)}"
               for k,v in self.__entries.items()]
        ret = f"{{\n{'':{indent}}" + f",\n{'':{indent}}".join(ret) + "\n"

        if indent > 2:
            ret += f"{'':{indent-2}}"
        ret += "}"
        return ret

    def lvalue(self, child=None):
        lv = self.container.lvalue(self) if self.container else self.name
        if child:
            lv += f'.{child.name}'
        return lv

class InstanceDataObject(DataObject):
    def __init__(self, typename, name,
               template_params = None,
               constructor_args = None,
               extern_c = False, alignment=None):
        DataObject.__init__(self, typename, name,
                            extern_c=extern_c, alignment=alignment)
        self.template_params = template_params
        self.constructor_args = constructor_args

    def source_element_declaration(self):
        """Builds an extern declaration of the data object"""
        template = ' '
        if self.template_params:
            template = '<'
            template += ",".join(self.template_params)
            template += '> '
        return Statement(self.generate_prefix()
                         + self.typename + template
                         + self.name)

    def source_element_allocation(self):
        """Builds an allocation statement for the object.

        If constructor_args are given, the constructor is called using
        this args

        Example: typename = 'Foo', name = 'x', constructor_args = [23, 5]
        emits:

        Foo x(23, 5);

        @return A Statement comprising the C++ allocation code
        """
        template = ' '
        if self.template_params:
            template = '<'
            template += ",".join(self.template_params)
            template += '> '
        args = '('
        args += ",".join(self.constructor_args)
        args += ')'

        return Statement(self.allocation_prefix
                         + self.typename + template
                         + self.name + args)

class DataObjectManager:
    def __init__(self, _log):
        # Namespace -> [DataObjects]
        self.__objects = {}
        self._log = _log.getChild(self.__class__.__name__)

    def objects(self):
        """Iterate over all namespaces and collect all data objects"""
        ret = []
        for obj_list in self.__objects.values():
            ret.extend(obj_list)
        return ret

    def add(self, obj, phase = 0, namespace=None):
        self._log.debug("add: %s", obj)
        obj.data_object_manager = self
        # Check whether data object was already defined with that
        # name/type:
        for old_obj in self.objects():
            if obj.name == old_obj.name:
                assert obj.typename == old_obj.typename, "Variable %s already defined with different type" % obj.name
                # Do not add another instance for this object
                if isinstance(obj, ExternalDataObject) and isinstance(old_obj, ExternalDataObject):
                    self._log.debug("skipping duplicate extern declaration: %s", obj)
                    continue
                raise ValueError(f"duplicated element {obj.name} ({obj.typename})")
        obj.phase = phase

        if not namespace in self.__objects:
            self.__objects[namespace] = []
        self.__objects[namespace].append(obj)

    def __iterate_in_namespaces(self, func):
        ret = []
        for namespace in self.__objects:
            if namespace is None:
                for x in func(self.__objects[None]):
                    ret.append( x )
            else:
                namespaces = list(namespace)
                assert len(namespaces) > 0
                ns = Block("namespace " + namespaces[0])
                last = ns
                for x in namespaces[1:]:
                    n = Block("namespace " + x)
                    last.add(n)
                    last = n

                for x in func(self.__objects[namespace]):
                    last.add( x )

                ret += [ns, "\n"]

        return ret

    def source_element_declaration(self):
        def iterate(objects):
            ret = []
            for o in objects:
                ret.append(o.source_element_declaration())
            return ret
        return self.__iterate_in_namespaces(iterate) + ["\n"]

    def source_element_allocation(self):
        def iterate(objects):
            ret = []
            for o in objects:
                ret.append(o.source_element_allocation())
            return ret
        ret =  self.__iterate_in_namespaces(iterate)
        for namespace in self.__objects:
            if namespace:
                ret += [Statement("using namespace " + "::".join(list(namespace)))]

        return ret + ["\n"]

    def source_element_initializer(self):
        # assert False, "Not implemented yet"
        return []

    def get_nullptr(self):
        return namedtuple('nullptr', ['name', 'address'])('nullptr', 'nullptr')
