import graph
import json
import os
import sys

from native_step import Step



class OilStep(Step):
    """Reads an oil file and writes all information to the graph."""
    
    def get_dependencies(self):
        
        return ["IntermediateAnalysisStep"]
    
    def validate_linked_resource(self, element):
    
        result = false
        #iterate about the attributes of the events
        for attribute in element:
            
            if attribute == "RESOURCEPROPERTY":
                
                if isinstance(element[attribute] , dict):
                    linked_dict = element[attribute]
                    for linked_attribute in linked_dict:
                        if linked_attribute == "LINKED":
                            result = true
                            break
                        
                if isinstance(element[attribute] , str):
                    #print(oil_counter[attribute])
                    if element[attribute] == "STANDARD":
                        result = true
                        break
                    
    def get_category_ISR(self,attributes):
    
        attribute = attributes.get("CATEGORY", "error")
        
        if attribute != "error":
            if isinstance(attribute, int):
                if not (attribute == 1 or attribute == 2):
                    print("category is not 1 or 2")
            else:
                print("category is no int")
        else:
            print("ISR has no category attribute")
        
        return attribute



    def run(self, g: graph.PyGraph):

    
        print("Run ", self.get_name())
        
        structure_file = '../appl/OSEK/coptermok.oil'
        tmp_file = '../tmp.txt'
        
        #open oil file
        f_old = open(structure_file)
        
        #print(f_old)
        
        #generate tmp file
        f_new = open(tmp_file, 'w')
        
        
        #ignore // comments
        for i in f_old.readlines():
            if not "//" in i:
                f_new.write(i)
                
        #close the files
        f_new.close()
        f_old.close()
        
        #load the json outputstructure with json
        with open(tmp_file) as f:
            dictionary = json.load(f)
        
        
        #remove tmp file
        os.remove(tmp_file)
        
        #generate instances
        counter_list = {}
        isr_list = {}
        task_list = {}
        event_list = {}
        resource_list = {}
        alarm_list = {}
        
        #get the rtos graph instances
        rtos =  g.get_type_vertices("RTOS")
        
        #just one rtos instance should exist
        if len(rtos) != 1:
            print("rtos could not load")
            sys.exit()
            
            
        #get the os
        rtos = dictionary.get("OS", "error")
        if rtos != "error":
            #iterate about the os attributes and store values in rtos instance
            for attribute in rtos:
                if attribute == "STATUS":
                    rtos.set_status(rtos[attribute])
                elif attribute == "ERRORHOOK":
                    rtos.enable_error_hook(rtos[attribute])
                elif attribute == "PRETASKHOOK":
                    rtos.enable_pretask_hook(rtos[attribute])
                elif attribute == "POSTTASKHOOK":
                    rtos.enable_posttask_hook(rtos[attribute])
                elif attribute == "STARTUPHOOK":
                    rtos.enable_startup_hook(rtos[attribute])
                elif attribute == "SHUTDOWNHOOK":
                    rtos.enable_shutdown_hook(rtos[attribute])
                else:
                    print("unexpected rtos attribute",attribute)
                    sys.exit()
                  
        #TODO get appmode from startos call
        
        
        #get the isrs
        isrs = dictionary.get("ISR", "error")
        if isrs != "error":
            #iterate about the isr
            for name in isrs:
                isr = graph.ISR(g, name)
                #print("name of isr: ", isr.get_name())
                isr_list[name]= isr
                g.set_vertex(isr)
             
        
        #get the counters 
        counters = dictionary.get("COUNTER", "error")
        if counters != "error":
            #iterate about the counter
            for name in counters:
                counter = graph.Counter(g, name)
                counter_list[name] = counter
                g.set_vertex(counter)
           
                
        #get the events
        events = dictionary.get("EVENT", "error")
        if events != "error":
            #iterate about the counter
            for name in events:
                event = graph.Event(g, name)
                event_list[name] = event
                g.set_vertex(event)
   
                
        #get the tasks
        tasks = dictionary.get("TASK", "error")
        if tasks != "error":
            #iterate about the tasks
            for name in tasks:
                
                task = graph.Task(g, name)
                task_list[name] = task
                g.set_vertex(task)
     
        #get the resources
        resources = dictionary.get("RESOURCE", "error")
        if resources != "error":
            #iterate about the isr
            for name in resources:
                resource = graph.Resource(g, name)
                resource_list[name] = resource
                g.set_vertex(resource)

 
        #get the alarms
        alarms = dictionary.get("ALARM", "error")
        if alarms != "error":
            #iterate about the alarms
            for name in alarms:
                alarm = graph.Timer(g, name)
                alarm_list[name] = alarm
                g.set_vertex(alarm)


        #get the counters 
        counters = dictionary.get("COUNTER", "error")
        if counters != "error":

            #iterate about the counter
            for name in counters:
                
                #shared pointer counter reference
                counter = counter_list[name]
                
                oil_counter = counters[name]
                
                #iterate about the attributes of the counter
                for attribute in oil_counter:
                    
                    if attribute == "MAXALLOWEDVALUE":
                        if isinstance(oil_counter[attribute] , int):
                            counter.set_max_allowed_value(oil_counter[attribute])
                            
                        else:
                            print("maxallowed value is no digit")
                            
                    elif attribute == "TICKSPERBASE":
                        if isinstance(oil_counter[attribute] , int):
                            counter.set_ticks_per_base(oil_counter[attribute])
                            
                        else:
                            print("ticksperbase value is no digit")
                            
                    elif attribute == "MINCYCLE":
                        if isinstance(oil_counter[attribute] , int):
                            counter.set_min_cycle(oil_counter[attribute])
                    
                        else:
                            print("mincycle value is no digit")
                    else:
                        print(attribute ,";counter has other attribute than MAXALLOWEDVALUE or TICKSPERBASE or MINCYCLE")
                    
        
        
        
                    
        #get the resources 
        resources = dictionary.get("RESOURCE", {})
        if resources != "error":

            #iterate about the events
            for name in resources:
                
                resource = resource_list[name]
                
                #print (name, 'corresponds to', resources[name])
                oil_resource = resources[name]
                
                resource.set_handler_name("OSEKOS_RESOURCE_" + name)
                
                #iterate about the attributes of the events
                for attribute in oil_resource:
                    
                    if attribute == "RESOURCEPROPERTY":
                        
                        if isinstance(oil_resource[attribute] , dict):
                            linked_dict = oil_resource[attribute]
                            for linked_attribute in linked_dict:
                                if linked_attribute == "LINKED":
                                    if isinstance(linked_dict[linked_attribute], str):
                                        if linked_dict[linked_attribute] in resource_list:
                                            if validate_linked_resource(linked_dict[linked_attribute]):
                                                if not resource.set_resource_property(oil_resource[attribute],linked_dict[linked_attribute]):
                                                    print("resource could not linked", linked_dict[linked_attribute])
                                            else:
                                                print("linked resource has no linked or normal attribute value")
                                        else:
                                            print("resource was not defined in OIL: ", linked_dict[linked_attribute])
                                    else:
                                        print("linked resource is no string")
                                else:
                                    print("linked attribute is no dictionary")
                        if isinstance(oil_resource[attribute] , str):
                            #print(oil_counter[attribute])
                            if oil_resource[attribute] == "STANDARD" or oil_resource[attribute] == "INTERNAL":
                                resource.set_resource_property(oil_resource[attribute], "")
                                #print("resource attribute: " ,oil_resource[attribute])
                            else:
                                print("resource has other attribute than STANDARD or LINKED or INTERNAL")
                        else:
                            print("resourceproperty is no string or dictionary")
                    else:
                        print("resource has other attribute than RESOURCEPROPERTY")
        
        
        #get the events 
        events = dictionary.get("EVENT", "error")
        if events != "error":

            #iterate about the events
            for name in events:
                
                event = event_list[name]
                
                #print (name, 'corresponds to', events[name])
                oil_event = events[name]
                
                event.set_handler_name("OSEKOS_EVENT_" + name);
                
                #iterate about the attributes of the events
                for attribute in oil_event:
                    
                    if attribute == "MASK":
                        if oil_event[attribute] == "AUTO":
                            event.set_event_mask_auto();
                            #print(oil_event[attribute])
                        elif isinstance(oil_event[attribute] , int):
                            event.set_event_mask(oil_event[attribute])
                            #print(oil_event[attribute])
                        else:
                            print("eventmask is not auto or digit")
                            
                    else:
                        print("event has no different attribute than mask")
                    
                    
        #get the tasks
        tasks = dictionary.get("TASK", "error")		
        if tasks != "error":
            
            #iterate about the tasks
            for name in tasks:
                
                task = task_list[name]
                #print (name, 'corresponds to', tasks[name])
                function_list = g.get_type_vertices(type(graph.Function))
                
                #set and check function reference of task
                if not task.set_definition_function("OSEKOS_TASK_FUNC_" + name):
                    print("Task ", name, " has no reference in data")
                    sys.exit()
                    
                task.set_handler_name("OSEKOS_TASK_" +name)
                
                #iterate about the attributes of the task
                oil_task = tasks[name]
                for attribute in oil_task:
                    
                    #print (attribute, 'is = ', oil_task[attribute])
                    
                    if attribute ==	"PRIORITY":
                        
                        if isinstance(oil_task[attribute], int):
                            #print("priority: ", oil_task[attribute])
                            task.set_priority(oil_task[attribute])
                        else:
                            print("priority is no digit")
                            
                    elif attribute ==	"AUTOSTART":
                        autostart_attribute = oil_task[attribute]
                        if isinstance(autostart_attribute,dict):
                            for appmodes in autostart_attribute:
                                if appmodes == "TRUE":
                                    task.set_autostart(True)
                                    if isinstance(autostart_attribute[appmodes],list):
                                        for appmode in appmodes:
                                            #print("autostart: ", autostart_attribute)
                                            #print("appmode: ", appmode)
                                            task.set_appmode(appmode)
                                else:
                                    print("autostart is no boolean")
                                    sys.exit()
                        else:
                            if "FALSE" == autostart_attribute:
                                #print("autostart: ", autostart_attribute)
                                task.set_autostart(False)
                            else:
                                print("autostart is no boolean")
                                sys.exit()
                                
                    elif attribute ==	"ACTIVATION": 	
                        if isinstance(oil_task[attribute], int):
                            #print("activation: ", oil_task[attribute])
                            task.set_activation(oil_task[attribute])
                        else:
                            print("activation is no digit")
                            sys.exit()
                            
                    elif attribute ==	"SCHEDULE":
                        if oil_task[attribute] == "NONE" or oil_task[attribute] == "FULL":
                            #print("schedule: ", oil_task[attribute])
                            task.set_scheduler(oil_task[attribute])
                        else:
                            print("schedule is not none or full")
                            sys.exit()
                    
                    elif attribute ==	"RESOURCE":
                        if isinstance(oil_task[attribute], list):
                            for resource in oil_task[attribute]:
                                if isinstance(resource, str):
                                    #print("resource: ",resource)
                                    task.set_resource_reference(resource)
                                else:
                                    print("resource is no string")
                                
                    elif attribute ==	"EVENT":
                        if isinstance(oil_task[attribute], list):
                            for event in oil_task[attribute]:
                                if isinstance(event, str):
                                    if event in event_list:
                                        #print("event: ", event)
                                        task.set_event_reference(event)
                                    else:
                                        print("event was not defined in OIL: ", event)
                                        sys.exit()
                                else:
                                    print("event is no string")
                                    sys.exit()
                                
                    elif attribute ==	"MESSAGE":
                        if isinstance(oil_task[attribute], list):
                            for message in oil_task[attribute]:
                                if isinstance(message, str):
                                    if message in message_list:
                                        print("message: ", message)
                                        sys.exit()
                                        #task.set_message_reference(message)
                                    else:
                                        print("message was not defined in OIL:", message)
                                        sys.exit()
                                else:
                                    print("message is no string")
                                    sys.exit()
                                    
                                    
            
        
        #get the isrs
        isrs = dictionary.get("ISR", "error")
        if isrs != "error":
            
            #iterate about the isrs
            for name in isrs:
                
                #create isr
                isr = isr_list[name]
                
            
                #print (name, 'corresponds to', isrs[name])
                oil_isr = isrs[name]
            
                isr.set_handler_name("OSEKOS_ISR_" +name)
            
                function_list = g.get_type_vertices(type(graph.Function))
                
                reference_function = name
                if self.get_category_ISR(oil_isr) == 2:
                    reference_function = "OSEKOS_ISR_" + name
                
                if not isr.set_definition_function(reference_function):
                    print("ISR ", name, " has no definition reference in data")
                    sys.exit()
                
                #iterate about the attributes of the isr
                for attribute in oil_isr:
                    
                    if attribute ==	"CATEGORY":
                        if isinstance(oil_isr[attribute], int):
                            if oil_isr[attribute] == 1 or oil_isr[attribute] == 2:
                                #print("category: " , oil_isr[attribute])
                                isr.set_category(oil_isr[attribute])
                            else:
                                print("category is not 1 or 2")
                                sys.exit()
                        else:
                            print("category is no string")
                            sys.exit()
                            
                    elif attribute ==	"RESOURCE":
                        if isinstance(oil_isr[attribute], list):
                            for resource in oil_isr[attribute]:
                                if isinstance(resource, str):
                                    if resource in resource_list:
                                        #print("resource: ",resource)
                                        isr.set_resource_reference(resource)
                                    else:
                                        print("resource was not defined in OIL: ", resource)
                                        sys.exit()
                                else:
                                    print("resource is no string")
                                    sys.exit()
                                
                    elif attribute ==	"MESSAGE":
                        if isinstance(oil_isr[attribute], list):
                            for message in oil_isr[attribute]:
                                #TODO
                                if not isinstance(message, str):
                                    print("message is no string")
                                    sys.exit()
                                    #if message in message_list:
                                        
                                        #isr.set_message_reference(message)
                                    #else:
                                    #	print("message was not defined in OIL: ", message)
                                
                                    
                                            
                
            
                    
        #get the alarms 
        alarms = dictionary.get("ALARM", "error")
        if alarms != "error":

            #iterate about the alarms
            for name in alarms:
                
                alarm = alarm_list[name]
                
                #print (name, 'corresponds to', alarms[name])
                oil_alarm = alarms[name]
                
                alarm.set_handler_name("OSEKOS_ALARM_" +name)
                
                
                #iterate about the attributes of the alarms
                for attribute in oil_alarm:
                    
                    if attribute ==	"COUNTER":
                        if isinstance(oil_alarm[attribute], str):
                            #print("counter: " , oil_alarm[attribute])
                            alarm.set_counter_reference(oil_alarm[attribute])
                        else:
                            print("counter is no string")
                            sys.exit()
                        
                    elif attribute ==	"ACTION":
                        for action_attribute in oil_alarm[attribute]:
                            if action_attribute == "ACTIVATETASK":
                                
                                activatetask_attributes = oil_alarm[attribute][action_attribute]
                                print(activatetask_attributes)
                                for activatetask_attribute in activatetask_attributes:
                                    #print(activatetask_attribute)
                                    if activatetask_attribute == "TASK": 
                                        if isinstance(activatetask_attributes[activatetask_attribute], str):
                                            if activatetask_attributes[activatetask_attribute] in task_list:
                                                #print("activatetask: " , activatetask_attributes[activatetask_attribute])
                                                alarm.set_task_reference(activatetask_attributes[activatetask_attribute])
                                            else:
                                                print("task was not defined in OIL file: ", activatetask_attributes[activatetask_attribute])
                                                sys.exit()
                                        else:
                                            print("activatetask has no string attribute")
                                            sys.exit()
                                    else:
                                        print("activatetask has no attribute task")
                                        sys.exit()
                                        
                            elif action_attribute == "SETEVENT":
                                set_event_attributes = oil_alarm[attribute]
                                for set_event_attribute in set_event_attributes:
                                    if set_event_attribute == "TASK": 
                                        if isinstance(set_event_attributes[set_event_attribute], str):
                                            if set_event_attributes[set_event_attribute] in event_list:
                                                #print("setevent task: " ,set_event_attributes[set_event_attribute])
                                                alarm.set_task_reference(set_event_attributes[set_event_attribute])
                                            else: 
                                                print("event was not defined in OIL file: ", set_event_attributes[set_event_attribute])
                                                sys.exit()
                                        else:
                                            print("setevent has no string attribute")
                                            sys.exit()
                                            
                                    elif activatetask_attribute == "EVENT": 	
                                        if isinstance(set_event_attributes[set_event_attribute], str):
                                            if set_event_attributes[set_event_attribute] in event_list:
                                                #print("setevent event: " ,set_event_attributes[set_event_attribute])
                                                alarm.set_event_reference(set_event_attributes[set_event_attribute])
                                            else:
                                                print("event was not defined in OIL file: ", set_event_attributes[set_event_attribute])
                                                sys.exit()
                                        else:
                                            print("setevent has no string attribute")
                                            sys.exit()
                                                
                                    else:
                                        print("activatetask has no attribute task")
                                        sys.exit()
                            
                            elif action_attribute == "ALARMCALLBACK)":
                                alarmcallback_attributes = oil_alarm[attribute]
                                for alarmcallback_attribute in alarmcallback_attributes:
                                    if alarmcallback_attribute == "ALARMCALLBACKNAME": 
                                        if isinstance(alarmcallback_attributes[alarmcallback_attribute], str):
                                            #print("alarmcallback alarmcallbackname: " , activatetask_attributes[activatetask_attribute])
                                            alarm.set_callback_function(activatetask_attributes[activatetask_attribute])
                                        else:
                                            print("alarmcallback has no string attribute")
                                            sys.exit()
                                    else:
                                        print("alarmcallback has no attribute alarmcallbackname")
                                        sys.exit()
                                
                                
                            else:
                                print("counter is not ACTIVATETASK or SETEVENT or ALARMCALLBACK",print(attribute))
                                sys.exit()
                            
    

                    elif attribute ==	"AUTOSTART":
                       
                        autostart_attribute = oil_alarm[attribute]
            
                        if isinstance(autostart_attribute, str):
                            if autostart_attribute == "FALSE":
                                alarm.set_timer_type(graph.timer_type.autostart)
                        else:
                            for autostart in autostart_attribute:
                                if autostart == "TRUE":
                                    alarm.set_timer_type(graph.timer_type.autostart)
                                    #print("autostart: ",autostart)
                                    autostart_dict =  autostart_attribute[autostart]
                                    if isinstance( autostart_dict, dict):
                                        for tmp_attribute in autostart_dict:
                                            
                                            if tmp_attribute == "ALARMTIME":
                                                if isinstance(autostart_dict[tmp_attribute], int):
                                                    alarm.set_alarm_time(autostart_dict[tmp_attribute])
                                                    #print("alarmtime: ", autostart_dict[tmp_attribute])
                                                else:
                                                    print("autostart alarmtime is no int")

                                            elif tmp_attribute == "CYCLETIME":
                                                if isinstance(autostart_dict[tmp_attribute], int):
                                                    alarm.set_cycle_time(autostart_dict[tmp_attribute])
                                            
                                                else:
                                                    print("autostart cycletime is no int")
                                            elif tmp_attribute == "APPMODE":
                                                if isinstance(autostart_dict[tmp_attribute], list):
                                                    for appmode in autostart_dict[tmp_attribute]:
                                                        if isinstance(appmode, str):
                                                            #("appmode: ",appmode)
                                                            alarm.set_appmode(appmode)
        
                                                        else:
                                                            print("appmode is no string")
                                                            sys.exit()
                                                else:
                                                    print("appmode is no list")
                                                    sys.exit()
                                            else:
                                                print("no ALARMTIME or CYCLETIME or APPMODE in autostart" ,autostart_attribute)
                                                sys.exit()
                                    else:
                                        print("autostart is no dict")
                                        sys.exit()
                                    
                                else:
                                    print("autostart is no boolean")
                                    sys.exit()
            

