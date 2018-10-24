import graph
import json
import os


from native_passage import Passage


class OilPassage(Passage):
	"""Reads an oil file and writes all information to the graph."""
	

	def run(self, graph: graph.PyGraph):

		structure_file = '../appl/OSEK/oilfile.oil'
		tmp_file = '../tmp.txt'
		
		#open oil file
		f_old = open(structure_file)
		
		print(f_old)
		
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
		timer_list = {}
		isr_list = {}
		task_list = {}
		event_list = {}
		resource_list = {}
		alarm_list = {}
		
		#get the counters 
		counters = dictionary.get("COUNTER", "error")
		if counters != "error":
			#iterate about the counter
			for name in counters:
				print("TEST")
				#TODO counter = Counter(graph, name)
				#counter_list[name] = counter
		
		#get the events
		events = dictionary.get("EVENT", "error")
		if events != "error":
			#iterate about the counter
			for name in events:
				print("TEST")
				#TODO event = Event(graph, name)
				#event_list[name] = event

		#get the isrs
		isrs = dictionary.get("ISR", "error")
		if isrs != "error":
			#iterate about the isr
			for name in isrs:
				print("TEST")
				#TODO isr = ISR(graph, name)
				#isr_list[name] = isr
				
		#get the tasks
		tasks = dictionary.get("TASK", "error")
		if tasks != "error":
			#iterate about the tasks
			for name in tasks:
				print("TEST")
				#TODO task = Task(graph, name)
				#task_list[name] = task
			
		#get the resources
		resources = dictionary.get("RESOURCE", "error")
		if resources != "error":
			#iterate about the isr
			for name in isrs:
				print("TEST")
				#TODO resource = Resource(graph, name)
				#resource_list[name] = resource
				
		#get the alarms
		alarms = dictionary.get("ALARM", "error")
		if alarms != "error":
			#iterate about the alarms
			for name in alarms:
				print("TEST")
				#TODO alarm = Alarm(graph, name)
				#alarm_list[name] = alarm
				
		#get the timers
		timers = dictionary.get("TIMER", "error")
		if timers != "error":
			#iterate about the timers
			for name in timers:
				print("TEST")
				#TODO timer = Timer(graph, name)
				timer_list[name] = timer
				
				
				
				
		#get the counters 
		counters = dictionary.get("COUNTER", "error")
		if counters != "error":

			#iterate about the counter
			for name in counters:
				
				#TODO counter
				
				print (name, 'corresponds to', counters[name])
				oil_counter = counters[name]
				
				#iterate about the attributes of the counter
				for attribute in oil_counter:
					
					if attribute == "MAXALLOWEDVALUE":
						if isinstance(oil_counter[attribute] , int):
							#TODO counter.set_max_allowed_value(oil_counter[attribute])
							print("maxallowedvalue" ,[attribute])
						else:
							print("maxallowed value is no digit")
							
					elif attribute == "TICKSPERBASE":
						if isinstance(oil_counter[attribute] , int):
							#TODO counter.set_ticks_per_base(oil_counter[attribute])
							print("ticksperbase: " , oil_counter[attribute])
						else:
							print("ticksperbase value is no digit")
							
					elif attribute == "MINCYCLE":
						if isinstance(oil_counter[attribute] , int):
							#TODO counter.set_min_cycle(oil_counter[attribute])
							print("mincycle: ", oil_counter[attribute])
						else:
							print("mincycle value is no digit")
					else:
						print(attribute ,";counter has other attribute than MAXALLOWEDVALUE or TICKSPERBASE or MINCYCLE")
					
					
		#get the resources 
		resources = dictionary.get("RESOURCE", {})
		if resources != "error":

			#iterate about the events
			for name in resources:
				
				#TODO resource = Resource(graph, name) 
				print (name, 'corresponds to', resources[name])
				oil_resource = resources[name]
				
				#iterate about the attributes of the events
				for attribute in oil_resource:
					
					if attribute == "RESOURCEPROPERTY":
						
						if isinstance(oil_resource[attribute] , dict):
							linked_dict = oil_resource[attribute]
							for linked_attribute in linked_dict:
								if linked_attribute == "LINKED":
									if isinstance(linked_dict[linked_attribute], str):
										#TODO resource.set_resource_property(oil_resource[attribute],linked_dict[linked_attribute])
										print("linked: " , oil_resource[attribute],linked_dict[linked_attribute])
									else:
										print("linked resource is no string")
								else:
									print("linked attribute is no dictionary")
						if isinstance(oil_resource[attribute] , str):
							#print(oil_counter[attribute])
							if oil_resource[attribute] == "STANDARD" or oil_resource[attribute] == "INTERNAL":
								#TODO resource.set_resource_property(oil_resource[attribute], "")
								print("resource attribute: " ,oil_resource[attribute])
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
				
				#TODO event = Event(graph, name)
				print (name, 'corresponds to', events[name])
				oil_event = events[name]
				
				#iterate about the attributes of the events
				for attribute in oil_event:
					
					if attribute == "MASK":
						if oil_event[attribute] == "AUTO":
							#TODO event.set_mask_auto();
							print(oil_event[attribute])
						elif isinstance(oil_event[attribute] , int):
							#TODO event.set_mask(oil_event[attribute])
							print(oil_event[attribute])
						else:
							print("eventmask is not auto or digit")
							
					else:
						print("event has no different attribute than mask")
					
					
		#get the tasks
		tasks = dictionary.get("TASK", "error")		
		if tasks != "error":
			
			#iterate about the tasks
			for name in tasks:
				
				#TODO task =  Task(graph, name)
				
				print (name, 'corresponds to', tasks[name])
				
				#iterate about the attributes of the task
				oil_task = tasks[name]
				for attribute in oil_task:
					
					#print (attribute, 'is = ', oil_task[attribute])
					
					if attribute ==	"PRIORITY":
						
						if isinstance(oil_task[attribute], int):
							print("priority: ", oil_task[attribute])
							#TODO task.set_priority(oil_task[attribute])
						else:
							print("priority is no digit")
							
					elif attribute ==	"AUTOSTART":
						autostart_attribute = oil_task[attribute]
						if isinstance(autostart_attribute,dict):
							for appmodes in autostart_attribute:
								if appmodes == "TRUE":
									#TODO task.set_autostart(True)
									if isinstance(autostart_attribute[appmodes],list):
										for appmode in appmodes:
											print("autostart: ", autostart_attribute)
											print("appmode: ", appmode)
											#TODO task.set_appmode(app_mode)
								else:
									print("autostart is no boolean")
						else:
							if "FALSE" == autostart_attribute:
								print("autostart: ", autostart_attribute)
								#TODO task.set_autostart(False)
							else:
								print("autostart is no boolean")
								
					elif attribute ==	"ACTIVATION": 	
						if isinstance(oil_task[attribute], int):
							print("activation: ", oil_task[attribute])
							#TODO task.set_activation(oil_task[attribute])
						else:
							print("activation is no digit")
							
					elif attribute ==	"SCHEDULE":
						if oil_task[attribute] == "NONE" or oil_task[attribute] == "FULL":
							print("schedule: ", oil_task[attribute])
							#TODO task.set_scheduler(oil_task[attribute])
						else:
							print("schedule is not none or full")
					
					elif attribute ==	"RESOURCE":
						if isinstance(oil_task[attribute], list):
							for resource in oil_task[attribute]:
								if isinstance(resource, str):
									print("resource: ",resource)
									#TODO task.set_resource_reference(resource)
								else:
									print("resource is no string")
								
					elif attribute ==	"EVENT":
						if isinstance(oil_task[attribute], list):
							for event in oil_task[attribute]:
								if isinstance(event, str):
									print("event: ", event)
									#TODO task.set_event_reference(event)
								else:
									print("event is no string")
								
					elif attribute ==	"MESSAGE":
						if isinstance(oil_task[attribute], list):
							for message in oil_task[attribute]:
								if isinstance(message, str):
									print("message: ", message)
									#TODO task.set_message_reference(message)
								else:
									print("message is no string")
		
		#get the isrs
		isrs = dictionary.get("ISR", "error")
		if isrs != "error":
			
			#iterate about the isrs
			for name in isrs:
				
				#create isr
				#TODO 	isr = "tmp" #Generieren des isrs -> isr = (graph, name);  generate isr from graph interface 
				#if not isr.set_function_reference(%&%):
				#	print("no function reference was found in graph")
				
				print (name, 'corresponds to', isrs[name])
				oil_isr = isrs[name]
				
				#iterate about the attributes of the isr
				for attribute in oil_isr:
					
					if attribute ==	"CATEGORY":
						if isinstance(oil_isr[attribute], int):
							if oil_isr[attribute] == 1 or oil_isr[attribute] == 2:
								print("category: " , oil_isr[attribute])
								#TODO isr.set_category(oil_isr[attribute])
							else:
								print("category is not 1 or 2")
						else:
							print("category is no string")
					
					elif attribute ==	"RESOURCE":
						if isinstance(oil_isr[attribute], list):
							for resource in oil_isr[attribute]:
								if isinstance(resource, str):
									print("resource: ",resource)
									#TODO isr.set_resource_reference(resource)
								else:
									print("resource is no string")
								
					elif attribute ==	"MESSAGE":
						if isinstance(oil_isr[attribute], list):
							for message in oil_isr[attribute]:
								if isinstance(message, str):
									print("message: ", message)
									#TODO isr.set_message_reference(message)
								else:
									print("message is no string")
					
		#get the alarms 
		alarms = dictionary.get("ALARM", "error")
		if alarms != "error":

			#iterate about the alarms
			for name in alarms:
				
				#TODO alarm =  Alarm(graph, name)
				print (name, 'corresponds to', alarms[name])
				oil_alarm = alarms[name]
				
				#iterate about the attributes of the alarms
				for attribute in oil_alarm:
					
					if attribute ==	"COUNTER":
						if isinstance(oil_alarm[attribute], str):
							print("counter: " , oil_alarm[attribute])
							#TODO  alarm.set_counter_reference(oil_alarm[attribute])
						else:
							print("counter is no string")
						
					elif attribute ==	"ACTION":
						
						if oil_alarm[attribute] == "ACTIVATETASK":
							activatetask_attributes = oil_alarm[attribute]
							for activatetask_attribute in activatetask_attributes:
								if activatetask_attribute == "TASK": 
									if isinstance(activatetask_attributes[activatetask_attribute], str):
										print("activatetask: " , activatetask_attributes[activatetask_attribute])
										#TODO alarm.set_task_reference(activatetask_attributes[activatetask_attribute])
									else:
										print("activatetask has no string attribute")
								else:
									print("activatetask has no attribute task")
									
						elif oil_alarm[attribute] == "SETEVENT":
							set_event_attributes = oil_alarm[attribute]
							for set_event_attribute in set_event_attributes:
								if set_event_attribute == "TASK": 
									if isinstance(set_event_attributes[set_event_attribute], str):
										print("setevent task: " ,set_event_attributes[set_event_attribute])
										#TODO alarm.set_task_reference(set_event_attributes[set_event_attribute])
									else:
										print("setevent has no string attribute")
										
								elif activatetask_attribute == "EVENT": 	
									if isinstance(set_event_attributes[set_event_attribute], str):
										print("setevent event: " ,set_event_attributes[set_event_attribute])
										#TODO alarm.set_event_reference(set_event_attributes[set_event_attribute])
									else:
										print("setevent has no string attribute")
											
								else:
									print("activatetask has no attribute task")
						
						elif attribute == "ALARMCALLBACK)":
							alarmcallback_attributes = oil_alarm[attribute]
							for alarmcallback_attribute in alarmcallback_attributes:
								if alarmcallback_attribute == "ALARMCALLBACKNAME": 
									if isinstance(alarmcallback_attributes[alarmcallback_attribute], str):
										print("alarmcallback alarmcallbackname: " , activatetask_attributes[activatetask_attribute])
										#TODO alarm.set_alarm_callback_reference(activatetask_attributes[activatetask_attribute])
									else:
										print("alarmcallback has no string attribute")
								else:
									print("alarmcallback has no attribute alarmcallbackname")
							
							
						else:
							print("counter is not ACTIVATETASK or SETEVENT or ALARMCALLBACK")
							
	

					elif attribute ==	"AUTOSTART":
						autostart_attribute = oil_alarm[attribute]
						for autostart in autostart_attribute:
							
							if autostart == "FALSE":
								#TODO alarm.set_autostart(False)
								print("autostart: ",autostart)
							elif autostart == "TRUE":
								#TODO alarm.set_autostart(True)
								print("autostart: ",autostart)
								autostart_dict =  autostart_attribute[autostart]
								if isinstance( autostart_dict, dict):
									for tmp_attribute in autostart_dict:
										
										if tmp_attribute == "ALARMTIME":
											if isinstance(autostart_dict[tmp_attribute], int):
												#TODO alarm.set_alarm_time(autostart_dict[tmp_attribute])
												print("alarmtime: ", autostart_dict[tmp_attribute])
											else:
												print("autostart alarmtime is no int")

										elif tmp_attribute == "CYCLETIME":
											if isinstance(autostart_dict[tmp_attribute], int):
												#TODO alarm.set_cycle_time(autostart_dict[tmp_attribute])
												print("cycletime: ", autostart_dict[tmp_attribute])
											else:
												print("autostart cycletime is no int")
										elif tmp_attribute == "APPMODE":
											if isinstance(autostart_dict[tmp_attribute], list):
												for appmode in autostart_dict[tmp_attribute]:
													if isinstance(appmode, str):
														print("appmode: ",appmode)
														#TODO alarm.set_appmode(appmode)
	
													else:
														print("appmode is no string")
											else:
												print("appmode is no list")
										else:
											print("no ALARMTIME or CYCLETIME or APPMODE in autostart" ,autostart_attribute)
								else:
									print("autostart is no dict")
								
							else:
								print("autostart is no boolean")
								
		
						
		print("I'm an OilPassage")
					
	def validate_reference(self, dictionary, element, abstraction):
		print("HELLO")

		
		
