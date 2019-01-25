// vim: set noet ts=4 sw=4:

#ifndef Warning_H
#define Warning_H

#include <assert.h>

#include "graph.h"
class Warning{
    
    
    public:
         
        OS::shared_abb warning_position;
        Warning(OS::shared_abb abb){
			// Warning must have a location
			assert(abb != nullptr);
            this->warning_position = abb;
        };
        
        virtual std::string  print_warning()  const  = 0;
            
        std::string  print() const{
            
            std::string stream = "";
            if(warning_position!= nullptr)stream += "Warning at abb " + warning_position->get_name() + ":\n";
            stream += print_warning();
            return stream;
        };
        
        
        virtual ~Warning() {};
};

typedef std::shared_ptr<Warning> shared_warning;

class BufferWarning : public Warning {
    private:
        OS::shared_buffer buffer;
    
    public:
        BufferWarning(OS::shared_buffer buffer,OS::shared_abb abb) : Warning(abb){
                this->buffer = buffer;
        }
        
    virtual std::string print_warning()  const override {
            std::string stream = "";
            stream + "Buffer " + buffer->get_name() + " has no single reader single writer access" + "\n";
            return stream;
        };
};

class QueueSetWarning : public Warning {
    private:
        OS::shared_queueset queueset;
        graph::shared_vertex accessed_element;
    
    public:
        QueueSetWarning(OS::shared_queueset queueset, graph::shared_vertex accessed_element,OS::shared_abb abb):Warning(abb){
            this->queueset = queueset;
            this->accessed_element = accessed_element;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream = "";
            stream += "QueueSet " + queueset->get_name() + " element " + accessed_element->get_name() + " is accessed directly without taking from queueset before" +"\n";
            return stream;
        };
};

class EventWarning : public Warning {
    private:
        OS::shared_event event;
        graph::shared_vertex waiting_element;
        unsigned long expected_bits;
        unsigned long set_bits;
    
    public:
        EventWarning(OS::shared_event event, graph::shared_vertex waiting_element,   unsigned long expected_bits,   unsigned long set_bits,OS::shared_abb abb):Warning(abb){
            this->event = event;
            this->waiting_element = waiting_element;
            this->set_bits = set_bits;
            this->expected_bits = expected_bits;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream = "";
            stream += "Vertex " + waiting_element->get_name() + "wait for bits in event " + event->get_name() +"\n";
            
            stream += " wait bits " +std::to_string(expected_bits) +"\n";
            stream += " set bits from other instances" +std::to_string(set_bits) +"\n";
            return stream;
        };
};


class EventWarningWrongListSize : public Warning {
    private:
        OS::shared_event event;
        graph::shared_vertex waiting_element;
        unsigned long eventlist_size ;
        unsigned long set_expected_bits;

    
    public:
        EventWarningWrongListSize(OS::shared_event event, graph::shared_vertex waiting_element,  unsigned long eventlist_size,   unsigned long set_expected_bits,OS::shared_abb abb):Warning(abb){
            this->event = event;
            this->waiting_element = waiting_element;
            this->eventlist_size = eventlist_size;
            this->set_expected_bits = set_expected_bits;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream = "";
            stream += "Vertex " + waiting_element->get_name() + "set/wait for bits in event " + event->get_name() +"with to less size\n";
            
            stream += "set/wait bits " +std::to_string(set_expected_bits) +"\n";
            stream += "eventlist size " +std::to_string(eventlist_size) +"\n";
            return stream;
        };
};

class EnableWarning : public Warning {
    private:
        graph::shared_vertex instance;
        std::string prefix = "";
    public:
        EnableWarning(std::string prefix, graph::shared_vertex instance,OS::shared_abb abb):Warning(abb){
            this->instance = instance;
            this->prefix = prefix;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream = prefix + "\n";
            stream +=  "Abstraction instance " + instance->get_name() + " is used without enabling the abstraction class in rtos configuration" +"\n";
            return stream;
        };
};


class ISRSyscallWarning : public Warning {
    private:
        OS::shared_abb abb;
        OS::shared_isr isr;
    
    public:
        ISRSyscallWarning(OS::shared_abb abb,OS::shared_isr isr):Warning(abb){
            this->abb = abb;
            this->isr = isr;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream = "";
            stream +=  "ISR " + isr->get_name() + " use syscall " + abb->get_syscall_name() + " without isr syscall api use (FromISR expected)" +"\n";
            return stream;
        };
};




class CriticalRegionWarning : public Warning {
    private:
        graph::shared_vertex vertex;
    
    public:
        CriticalRegionWarning(graph::shared_vertex vertex, OS::shared_abb abb):Warning(abb){
            this->vertex = vertex;
        };
        
        virtual std::string print_warning()  const override {
            std::string stream = "";
            stream += "Critical region starting in abb  " + warning_position->get_name() + " with syscall " + warning_position->get_syscall_name() + " does not certainly end in instance " + vertex->get_name() + "\n";
            return stream;
        };
};




class SemaphoreUseWarning : public Warning {
    private:
        OS::shared_semaphore semaphore;
        graph::shared_vertex vertex;
    
    public:
        SemaphoreUseWarning(OS::shared_semaphore semaphore,graph::shared_vertex vertex, OS::shared_abb abb):Warning(abb){
            this->semaphore = semaphore;
            this->vertex = vertex;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream = "";
            stream += "Semaphore" +  semaphore->get_name() + "is taken in "+ vertex->get_name() +"but not given in other instance" + "\n";
            return stream;
        }
};

class ResourceUseWarning : public Warning {
    private:
        OS::shared_resource resouce;
        graph::shared_vertex vertex;
    
    public:
        ResourceUseWarning(OS::shared_resource resouce,graph::shared_vertex vertex, OS::shared_abb abb):Warning(abb){
            this->resouce = resouce;
            this->vertex = vertex;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream = "";
            stream += "Resouce" +  resouce->get_name() + "is taken in " + vertex->get_name() + "but not given in same instance" + "\n";
            return stream;
        }
};


class PriorityInversionWarning : public Warning {
    private:
        OS::shared_task max_prio_vertex ;
        OS::shared_task min_prio_vertex ;
        OS::shared_resource resource;
        
        std::vector<OS::shared_task> indirect_blocking_vertexes ;
        
    
    public:
        PriorityInversionWarning( std::vector<OS::shared_task>* indirect_blocking_vertexes,OS::shared_task min_prio_vertex,OS::shared_task max_prio_vertex, OS::shared_resource resource, OS::shared_abb abb):Warning(abb){
            this->indirect_blocking_vertexes = *indirect_blocking_vertexes;
            this->min_prio_vertex = min_prio_vertex;
            this->max_prio_vertex = max_prio_vertex;
            this->resource = resource;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream  = "";
            stream += "Possible unbounded priority inversion detected:\n";
            stream += "Resouce " + resource->get_name() + " is taken by\n";
            stream += "Vertex min " + min_prio_vertex->get_name() + " with priority " + std::to_string(min_prio_vertex->get_priority()) + "\n";
            stream += "Vertex max " + max_prio_vertex->get_name() + " with priority " + std::to_string(max_prio_vertex->get_priority()) + "\n";  
            
            for(auto indirect_blocking_vertex: indirect_blocking_vertexes){
                stream += "Vertex " +  indirect_blocking_vertex->get_name() +  " with priority " + std::to_string(indirect_blocking_vertex->get_priority()) + " can block vertex max indirect" + "\n";
            }
            stream += "\n";
            return stream;
        }
};


class DeadLockWarning : public Warning {
    private:
        
        std::vector<graph::shared_vertex> deadlockchain ;
        
    
    public:
        
        DeadLockWarning( std::vector<graph::shared_vertex> *input_deadlockchain, OS::shared_abb abb):Warning(abb){
            this->deadlockchain = *input_deadlockchain;
        }
        
        virtual std::string print_warning()  const override {
            std::string stream  = "";
            stream += "Deadlockchain detected between vertexes:\n";
            
            for(auto deaedlock_element: (this->deadlockchain)){
                stream += "Vertex: " +  deaedlock_element->get_name() + "\n";
            }
            stream += "\n";
            return stream;
        }
};


inline std::ostream& operator<<(std::ostream& stream, 
                     const Warning& warning) {
    stream << warning.print(); //assuming you define print for matrix 
    return stream;
}


#endif //Validation_STEP_H
