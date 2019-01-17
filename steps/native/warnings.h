class Warning{
    
    public:
        virtual std::stringstream print_warning(){
            std::stringstream stream;
            return stream;
        };
};

class BufferWarning : public Warning {
    private:
        shared_buffer buffer;
    
    public:
        BufferWarning(shared_buffer buffer){
                this->buffer = buffer;
        }
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream << "Buffer " << buffer->get_name() << " has no single reader single writer access" <<std::endl;
            return stream;
        };
};

class QeueSetWarning : public Warning {
    private:
        shared_queueset queueset;
        shared_vertex accessed_element;
    
    public:
        QeueSetWarning(shared_queueset queueset, shared_vertex accessed_element){
            this->queueset = queueset;
            this->accessed_element = accessed_element;
        }
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream << "QueueSet " << queueset->get_name() << " element " << accessed_element->get_name() << " is accessed directly without taking from queueset before" <<std::endl;
            return stream;
        };
};

class EnableWarning : public Warning {
    private:
        shared_vertex instance;
    
    public:
        EnableWarning(shared_vertex instance){
                this->instance = instance;
        }
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream <<  "Abstraction instance " << instance->get_name() << " is used without enabling the abstraction class in rtos configuration" <<std::endl;
            return stream;
        };
};


class ISRSyscallWarning : public Warning {
    private:
        shared_abb abb;
        shared_isr isr;
    
    public:
        ISRSyscallWarning(shared_abb abb,shared_isr isr){
            this->abb = abb;
            this->isr = isr;
        }
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream <<  "ISR " << isr->get_name() << " use syscall " << abb->get_syscall_name() << " without isr syscall api use (FromISR expected)" <<std::endl;
            return stream;
        };
};




class CriticalRegionWarning : public Warning {
    private:
        shared_vertex vertex;
        shared_abb abb;
    
    public:
        CriticalRegionWarning(shared_vertex vertex, shared_abb abb){
            this->vertex = vertex;
            this->abb = abb;
        };
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream << "Critical region starting in abb  " << abb->get_name() << " with syscall " << abb->get_syscall_name() << " does not certainly end in instance " << vertex->get_name() << std::endl;
            return stream;
        };
};




class SemaphoreUseWarning : public Warning {
    private:
        shared_semaphore semaphore;
        shared_vertex vertex;
    
    public:
        SemaphoreUseWarning(shared_semaphore semaphore,shared_vertex vertex){
            this->semaphore = semaphore;
            this->vertex = vertex;
        }
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream << "Semaphore" <<  semaphore->get_name() << "is taken in "<< vertex->get_name() <<"but not given in other instance" << std::endl;
            return stream;
        }
};

class ResourceUseWarning : public Warning {
    private:
        shared_resource resouce;
        shared_vertex vertex;
    
    public:
        ResourceUseWarning(shared_resource resouce,shared_vertex vertex){
            this->resouce = resouce;
            this->vertex = vertex;
        }
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream << "Resouce" <<  resouce->get_name() << "is taken in " << vertex->get_name() << "but not given in same instance" << std::endl;
            return stream;
        }
};


class PriorityInversionWarning : public Warning {
    private:
        shared_task max_prio_vertex ;
        shared_task min_prio_vertex ;
        shared_resource resource;
        
        std::vector<shared_task> indirect_blocking_vertexes ;
        
    
    public:
        PriorityInversionWarning( std::vector<shared_task>* indirect_blocking_vertexes,shared_task min_prio_vertex,shared_task max_prio_vertex, shared_resource resource){
            this->indirect_blocking_vertexes = *indirect_blocking_vertexes;
            this->min_prio_vertex = min_prio_vertex;
            this->max_prio_vertex = max_prio_vertex;
            this->resource = resource;
        }
        
        std::stringstream print_warning() {
            std::stringstream stream;
            stream << "Possible unbounded priority inversion detected: " << std::endl;
            stream << "Resouce " << resource->get_name() << " is taken by" <<std::endl;
            stream << "Vertex min " << min_prio_vertex->get_name() << " with priority " << min_prio_vertex->get_priority() << std::endl;
            stream << "Vertex max " << max_prio_vertex->get_name() << " with priority " << max_prio_vertex->get_priority() << std::endl;  
            
            for(auto indirect_blocking_vertex: indirect_blocking_vertexes){
                stream << "Vertex " <<  indirect_blocking_vertex->get_name() <<  " with priority " << indirect_blocking_vertex->get_priority() << " can block vertex max indirect" << std::endl;
            }
            stream << std::endl;
            return stream;
        }
};


std::stringstream& operator<< (std::stringstream& stream, Warning& warning) {
 
    stream << warning.print_warning().str() <<std::endl;
    
    return stream;
};
