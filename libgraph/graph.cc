// vim: set noet ts=4 sw=4:

#include "graph.h"

#include <cassert>
#include <fstream>
#include <functional>
#include <iostream>
#include <stdexcept>
#include <string>
#include <tuple>
#include <vector>

using namespace graph;
using namespace llvm;

/*graph::Graph::Graph(std::shared_ptr<llvm::Module> module){
    llvm_module = module;
}
*/

template <typename T> bool contains(std::any a) {
	bool success = false;
	// std::cout <<  typeid( T ).hash_code() << "," <<a.type().hash_code()  << std::endl;
	try {
		// we do th::comparison with 'name' because across shared library boundries we get
		// two different type_info objects
		if ((typeid(T).hash_code() == a.type().hash_code())) {
			success = true;
			std::cout << "test_verify" << std::endl;
		}
	} catch (...) {
	}

	std::cout << success << std::endl;
	return success;
}

// print methods -------------------------------------------------------------------------------
void debug_argument(argument_data argument) {

	// const std::size_t tmp_int = typeid(int).hash_code();
	// const std::size_t tmp_double = typeid(double).hash_code();
	// const std::size_t tmp_string = typeid(std::string).hash_code();
	// const std::size_t tmp_long = typeid(long).hash_code();
	std::cerr << "Argument: ";
	/*
	std::string type_str;
	llvm::raw_string_ostream rso(type_str);
	type->print(rso);
	std::cout<< rso.str() << std::endl ;
	*/
	// std::cout << "reference: " << tmp_int << " " << tmp_double << " " << tmp_string << " " << tmp_long << std::endl;

	for (auto element : argument.value_list) {

		/*
		std::size_t const tmp = element.type().hash_code();
		if(tmp_int == tmp){
		    std::cerr << std::any_cast<int>(element)   <<'\n';
		}else if(tmp_double == tmp){
		    std::cerr << std::any_cast<double>(element)  << '\n';
		}else if(tmp_string == tmp){
		    std::cerr << std::any_cast<std::string>(element)  <<'\n';
		}else if(tmp_long == tmp){
		    std::cerr << std::any_cast<long>(element)   <<'\n';
		}else{
		    std::cerr << "[warning: cast not possible] type: " <<element.type().name()   <<'\n';
		}
		*/
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		element->print(rso);
		std::cout << rso.str();
		std::cerr << ", ";
	}
	/*

	if( tmp == tmp_double){
	    auto*  tmp_value = (std::any_cast< double >( &(*value) ));
	    std::cerr << " double" << std::endl;
	    information += std::to_string(*tmp_value);
	}
	//if( contains<std::string>( value ) ){
	if( tmp == tmp_string){
	    auto*  tmp_value = std::any_cast< std::string >( &(*value) );
	    std::cerr << " string" << std::endl;
	    //information += tmp_value;
	}
	if( tmp == tmp_long){
	    auto* tmp_value = (std::any_cast< long >( &(*value) ));
	    std::cerr << " long" << std::endl;
	    information += std::to_string(*tmp_value);
	}
	//std::cout << "test" << value.type().name() << "\n" << value.type().hash_code() << std::endl;
	if( tmp == tmp_int){

	    auto*tmp_value = (std::any_cast< int >( &(*value) ));
	    std::cerr << " int" << std::endl;
	    information += std::to_string(*tmp_value);
	}
	*/
}

// help function to use string in switch case statements
constexpr unsigned int str2int(const char* str, int h = 0) {
	return !str[h] ? 5381 : (str2int(str, h + 1) * 33) ^ str[h];
}

graph::Graph::~Graph() {}

graph::Graph::Graph() {}

void graph::Graph::set_llvm_module(std::shared_ptr<llvm::Module> module) { llvm_module = module; }

std::shared_ptr<llvm::Module> graph::Graph::get_llvm_module() { return this->llvm_module; }

void graph::Graph::set_vertex(shared_vertex vertex) {

	// std::cerr << vertex->get_name();

	if (vertex == nullptr) {
		std::cerr << " set nullptr in list";
	}

	this->vertices.emplace_back(vertex);
}

void graph::Graph::set_edge(shared_edge edge) { this->edges.emplace_back(edge); }

std::ostream& graph::operator<<(std::ostream& stream, const Graph& graph) {
	stream << "Graph:\n";
	stream << "All vertices:\n";
	for (const auto vertex : graph.vertices) {
		stream << ' ' << *vertex << '\n';
	}
	return stream;
}

shared_vertex graph::Graph::create_vertex() {
	shared_vertex vertex = std::make_shared<Vertex>(this, ""); // create shared po
	this->vertices.emplace_back(vertex);                       // store the shared pointer in the internal list
	return vertex;
}

shared_edge graph::Graph::create_edge() {
	shared_edge edge = std::make_shared<Edge>(); // create shared pointer
	this->edges.emplace_back(edge);              // store the shared pointer in the internal list
	return edge;
}

std::list<shared_vertex> graph::Graph::get_type_vertices(size_t type_info) {
	std::list<shared_vertex> tmp_list;
	std::list<shared_vertex>::iterator it = this->vertices.begin(); // iterate about the list elements

	for (; it != this->vertices.end(); ++it) {

		// std::cerr << "searched type: " << type_info << ";current type: " << (*it).get()->get_type() << std::endl;
		if (type_info == (*it).get()->get_type()) { // check if vertex is from wanted type
			// std::cerr << "succes\n";
			tmp_list.emplace_back((*it));
		}
	}
	return tmp_list;
}

shared_vertex graph::Graph::get_vertex(size_t seed) {
	// gebe Vertex mit dem entsprechenden hashValue zurück

	for (auto& vertex : this->vertices) {
		// gesuchter vertex gefunden
		if (seed == vertex->get_seed()) { // check if vertex is from wanted type
			return (vertex);
		}
	}
	return nullptr;
}

shared_vertex graph::Graph::get_vertex(std::string name) {
	// gebe Vertex mit dem entsprechenden hashValue zurück

	shared_vertex return_vertex;
	int counter = 0;
	// std::cerr << "_______________________" << std::endl;
	// std::cerr << "searched name: " <<  name << std::endl;
	for (auto& vertex : this->vertices) {
		//	std::cerr << vertex->get_name() << std::endl;
		if (name == vertex->get_name()) {
			counter++;
			return_vertex = vertex;
		}
	}
	// std::cerr << counter<<  std::endl;
	// std::cerr << "_______________________" << std::endl;
	if (counter == 1) {
		return return_vertex;
	} else {
		// std::cerr << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" << std::endl;

		return nullptr;
	}
}

shared_edge graph::Graph::get_edge(size_t seed) {
	// gebe edge mit dem entsprechenden hashValue zurück
	std::list<shared_edge>::iterator it = this->edges.begin(); // iterate about the list elements
	for (; it != this->edges.end(); ++it) {
		// gesuchter vertex gefunden
		if (seed == (*it)->get_seed()) { // check if vertex is from wanted type
			return (*it);
		}
	}
	return nullptr;
}

std::list<shared_vertex> graph::Graph::get_vertices() {
	std::list<shared_vertex> tmp_list;
	std::list<shared_vertex>::iterator it = this->vertices.begin(); // iterate about the list elements
	for (; it != this->vertices.end(); ++it) {
		tmp_list.emplace_back(*it);
	}
	return tmp_list;
}

std::list<shared_edge> graph::Graph::get_edges() {
	std::list<shared_edge> tmp_list;
	std::list<shared_edge>::iterator it = this->edges.begin(); // iterate about the list elements
	for (; it != this->edges.end(); ++it) {
		tmp_list.emplace_back(*it);
	}
	return tmp_list;
}

bool graph::Graph::remove_vertex(size_t seed) {
	bool success = false;
	std::list<shared_vertex>::iterator it = this->vertices.begin(); // iterate about the list elements
	for (; it != this->vertices.end(); ++it) {
		if (seed == (*it)->get_seed()) {
			// TODO remove edges
			it = this->vertices.erase(it--);
			success = true;
			break;
		}
	}
	return success;
}

bool graph::Graph::remove_vertex(graph::shared_vertex vertex) {
	bool success = false;
	std::list<shared_vertex>::iterator it = this->vertices.begin(); // iterate about the list elements
	for (; it != this->vertices.end(); ++it) {
		if (vertex->get_seed() == (*it)->get_seed()) {
			// TODO remove edges
			it = this->vertices.erase(it--);
			success = true;
			break;
		}
	}
	return success;
}

bool graph::Graph::remove_edge(shared_edge* edge) {
	bool success = false;
	std::list<shared_edge>::iterator it = this->edges.begin(); // iterate about the list elements
	for (; it != this->edges.end(); ++it) {
		if (edge->get()->get_seed() == (*it)->get_seed()) {
			// TODO remove edges
			it = this->edges.erase(it--);
			success = true;
			break;
		}
	}
	return success;
}

bool graph::Graph::contain_vertex(shared_vertex vertex) {
	bool success = false;
	std::list<shared_vertex>::iterator it = this->vertices.begin(); // iterate about the list elements
	for (; it != this->vertices.end(); ++it) {
		if (vertex->get_seed() == ((*it)->get_seed())) {
			success = true;
			break;
		}
	}
	return success;
}

bool graph::Graph::contain_edge(shared_edge edge) {
	bool success = false;
	std::list<shared_edge>::iterator it = this->edges.begin(); // iterate about the list elements
	for (; it != this->edges.end(); ++it) {
		if (edge->get_seed() == (*it)->get_seed()) {
			success = true;
			break;
		}
	}
	return success;
}

graph::Vertex::Vertex(Graph* graph, std::string name) {

	this->graph = graph;
	this->name = name;
	// std::cerr  << "name: " << this->name << "\n";
}

std::string graph::Vertex::get_name() const { return this->name; }

std::size_t graph::Vertex::get_seed() { return this->seed; }

bool graph::Vertex::set_outgoing_edge(shared_edge edge) {
	bool success = false;
	if (this->graph->contain_edge(edge)) {
		success = true;
		this->outgoing_edges.emplace_back(edge);
	}
	return success;
}

bool graph::Vertex::set_ingoing_edge(shared_edge edge) {
	bool success = false;
	if (this->graph->contain_edge(edge)) {
		success = true;
		this->ingoing_edges.emplace_back(edge);
	}
	return success;
}

bool graph::Vertex::set_outgoing_vertex(shared_vertex vertex) {
	bool success = false;
	if (this->graph->contain_vertex(vertex)) {
		success = true;
		this->outgoing_vertices.emplace_back(vertex);
	}
	return success;
}

bool graph::Vertex::set_ingoing_vertex(shared_vertex vertex) {
	bool success = false;
	if (this->graph->contain_vertex(vertex)) {
		success = true;
		this->ingoing_vertices.emplace_back(vertex);
	}
	return success;
}

bool graph::Vertex::remove_edge(shared_edge edge) {
	bool success = false;
	std::list<weak_edge>::iterator it = this->outgoing_edges.begin(); // iterate about the list elements
	for (; it != this->outgoing_edges.end(); ++it) {
		auto tmp_edge = (*it).lock();
		if (edge == tmp_edge) {
			it = this->outgoing_edges.erase(it--);
			success = true;
			break;
		}
	}
	for (it = this->ingoing_edges.begin(); it != this->ingoing_edges.end(); ++it) {
		auto tmp_edge = (*it).lock();
		if (edge == tmp_edge) {
			it = this->ingoing_edges.erase(it--);
			success = true;
			break;
		}
	}
	return success;
}

bool graph::Vertex::remove_vertex(shared_vertex vertex) {
	bool success = false;
	std::list<weak_vertex>::iterator it = this->outgoing_vertices.begin(); // iterate about the list elements
	// iterate about the outgoing vertices
	for (; it != this->outgoing_vertices.end(); ++it) {
		auto tmp_vertex = (*it).lock();
		if (vertex->get_seed() == tmp_vertex->get_seed()) {
			it = this->outgoing_vertices.erase(it--);
			success = true;
			break;
		}
	}
	// iterate about the ingoing vertices
	for (it = this->ingoing_vertices.begin(); it != this->ingoing_vertices.end(); ++it) {
		auto tmp_vertex = (*it).lock();
		if (vertex->get_seed() == tmp_vertex->get_seed()) {
			it = this->ingoing_vertices.erase(it--);
			success = true;
			break;
		}
	}
	return success;
}

std::list<graph::shared_vertex> graph::Vertex::get_specific_connected_vertices(size_t type_info) {
	std::list<shared_vertex> tmp_list;
	std::list<weak_vertex>::iterator it = this->outgoing_vertices.begin(); // iterate about the list elements
	// iterate about the outgoing vertices
	for (; it != this->outgoing_vertices.end(); ++it) {
		auto tmp_vertex = (*it).lock();
		if (tmp_vertex->get_type() == type_info) {
			tmp_list.emplace_back(tmp_vertex);
		}
	}
	// iterate about the ingoing vertices
	for (it = this->ingoing_vertices.begin(); it != this->ingoing_vertices.end(); ++it) {
		auto tmp_vertex = (*it).lock();
		if (tmp_vertex->get_type() == type_info) {
			tmp_list.emplace_back(tmp_vertex);
		}
	}
	return tmp_list;
}

// width search
std::list<graph::shared_vertex> wide_search(Vertex* start, graph::shared_vertex end) {
	std::list<graph::shared_vertex> tmp_list;
	/*//TODO
	std::queue<graph::shared_vertex> queue;
	queue.push(*start);
	tmp_list.emplace_back(start);
	std::vector<size_t> visited;
	visited.emplace_back(start->get_seed());
	//iterate about the queue with open elements
	while(!queue.empty()){
	    graph::shared_vertex tmp = queue.front();
	    queue.pop();
	    if(&tmp==&end) return tmp_list;
	    std::list<graph::shared_vertex> neighbours = tmp->get_outgoing_vertices();
	    std::list<graph::shared_vertex>::iterator it = neighbours.begin();

	    for(; it != neighbours.end(); ++it){
	        if(!(std::find(visited.begin(), visited.end(), (*it)->get_seed()) != visited.end())){
	            queue.push(*it);
	            tmp_list.emplace_back(*it);
	        }
	    }
	}
	*/
	return tmp_list;
}

std::list<graph::shared_vertex> graph::Vertex::get_vertex_chain(
    graph::shared_vertex vertex) { // Methode, die die Kette der Elemente vom Start bis zum Ziel Vertex zurück gibt,
	return wide_search(this,
	                   vertex); // interagieren die Betriebssystemabstrakionen nicht miteinader gebe nullptr zurück
}

std::list<graph::shared_vertex>
graph::Vertex::get_connected_vertices() { // Methode, die die mit diesem Knoten verbundenen Vertexes zurückgibt
	std::list<graph::shared_vertex> tmp_list;
	std::list<graph::weak_vertex>::iterator it = this->outgoing_vertices.begin(); // iterate about the list elements
	// iterate about the outgoing vertices
	for (; it != this->outgoing_vertices.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	// iterate about the ingoing vertices
	for (it = this->ingoing_vertices.begin(); it != this->ingoing_vertices.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	return tmp_list;
}

std::list<graph::shared_edge>
graph::Vertex::get_connected_edges() { // Methode, die die mit diesem Knoten verbundenen Edges zurückgibt

	std::list<graph::shared_edge> tmp_list;
	std::list<graph::weak_edge>::iterator it = this->outgoing_edges.begin(); // iterate about the list elements
	// iterate about the outgoing edges
	for (; it != this->outgoing_edges.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	// iterate about the ingoing edges
	for (it = this->ingoing_edges.begin(); it != this->ingoing_edges.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	return tmp_list;
}

std::list<graph::shared_vertex> graph::Vertex::get_ingoing_vertices() { // Methode, die die mit diesem Knoten
	                                                                    // eingehenden Vertexes zurückgibt
	std::list<graph::shared_vertex> tmp_list;
	std::list<graph::weak_vertex>::iterator it = this->ingoing_vertices.begin();
	for (; it != this->ingoing_vertices.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	return tmp_list;
}

std::list<graph::shared_edge>
graph::Vertex::get_ingoing_edges() { // Methode, die die mit diesem Knoten eingehenden Edges zurückgibt
	std::list<graph::shared_edge> tmp_list;
	std::list<graph::weak_edge>::iterator it = this->ingoing_edges.begin();
	for (; it != this->ingoing_edges.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	return tmp_list;
}

std::list<graph::shared_vertex>
graph::Vertex::get_outgoing_vertices() { // Methode, die die mit diesem Knoten ausgehenden Vertexes zurückgibt
	std::list<graph::shared_vertex> tmp_list;
	std::list<graph::weak_vertex>::iterator it = this->outgoing_vertices.begin();
	for (; it != this->outgoing_vertices.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	return tmp_list;
}

std::list<graph::shared_edge>
graph::Vertex::get_outgoing_edges() { // Methode, die die mit diesem Knoten ausgehenden Edges zurückgibt
	std::list<graph::shared_edge> tmp_list;
	std::list<graph::weak_edge>::iterator it = this->outgoing_edges.begin();
	for (; it != this->outgoing_edges.end(); ++it) {
		tmp_list.emplace_back((*it).lock());
	}
	return tmp_list;
}

llvm::Value* graph::Vertex::get_handler_value() { return this->handler_value; }

void graph::Vertex::set_handler_name(std::string handler_name, llvm::Value* handler_value) {
	this->handler_value = handler_value;
	this->handler_name = handler_name;
}

std::list<graph::shared_edge> graph::Vertex::get_direct_edge(
    graph::shared_vertex vertex) { // Methode, die direkte Kante zwischen Start und Ziel Vertex zurückgibt,
	std::list<graph::shared_edge> tmp_list;
	std::list<graph::weak_edge>::iterator it = this->outgoing_edges.begin(); // iterate about the list elements
	// iterate about the outgoing vertices
	for (; it != this->outgoing_edges.end(); ++it) {
		auto tmp_edge = (*it).lock();
		if (vertex->get_seed() == (tmp_edge->get_target_vertex()->get_seed())) {
			tmp_list.emplace_back(tmp_edge);
		}
	}
	// iterate about the ingoing verticesget
	for (it = this->ingoing_edges.begin(); it != this->ingoing_edges.end(); ++it) {
		auto tmp_edge = (*it).lock();
		if (vertex->get_seed() == (tmp_edge->get_start_vertex()->get_seed())) {
			tmp_list.emplace_back(tmp_edge);
		}
	}
	return tmp_list;
}

void graph::Vertex::set_type(std::size_t type) { this->vertex_type = type; }

std::size_t graph::Vertex::get_type() { return this->vertex_type; }

std::string graph::Vertex::get_handler_name() { return this->handler_name; }

void graph::Vertex::set_handler_name(std::string handler_name) { this->handler_name = handler_name; }

void graph::Vertex::set_start_scheduler_creation_flag(bool flag) { this->start_scheduler_creation_flag = flag; }

bool graph::Vertex::get_start_scheduler_creation_flag() { return this->start_scheduler_creation_flag; }

graph::Edge::Edge() {
	this->name = "";
	this->graph = nullptr;
}

graph::Edge::Edge(Graph* graph, std::string name, shared_vertex start, shared_vertex target,
                  shared_abb atomic_basic_block_reference) {
	this->name = name;
	this->graph = graph;
	this->start_vertex = start;
	this->target_vertex = target;
	this->atomic_basic_block_reference = atomic_basic_block_reference;
}

std::string graph::Edge::get_name() { return this->name; }
std::size_t graph::Edge::get_seed() { return this->seed; }

bool graph::Edge::set_start_vertex(graph::shared_vertex vertex) {
	bool success = false;
	if (this->graph->contain_vertex(vertex)) {
		success = true;
		this->start_vertex = vertex;
	}
	return success;
}

bool graph::Edge::set_target_vertex(graph::shared_vertex vertex) {
	bool success = false;
	if (this->graph->contain_vertex(vertex)) {
		success = true;
		this->target_vertex = vertex;
	}
	return success;
}

graph::shared_vertex graph::Edge::get_start_vertex() { return (this->start_vertex).lock(); }
graph::shared_vertex graph::Edge::get_target_vertex() { return (this->target_vertex).lock(); }

void graph::Edge::set_syscall(bool syscall) { this->is_syscall = syscall; }
bool graph::Edge::is_sycall() { return this->is_syscall; }

std::list<argument_data>* graph::Edge::get_arguments() {
	std::cout << "TEST";
	return &this->arguments;
}

void graph::Edge::set_arguments(std::list<argument_data> arguments) {
	this->arguments = arguments;
	return;
}

void graph::Edge::set_argument(argument_data argument) {
	this->arguments.emplace_back(argument);
	return;
}

void graph::Edge::set_instruction_reference(llvm::Instruction* reference) { this->instruction_reference = reference; }

llvm::Instruction* graph::Edge::get_instruction_reference() { return this->instruction_reference; }

OS::shared_abb graph::Edge::get_abb_reference() { return (this->atomic_basic_block_reference).lock(); }

void graph::Edge::set_specific_call(call_data* call) { this->call = *call; }

call_data graph::Edge::get_specific_call() { return this->call; }

bool OS::Function::remove_abb(size_t seed) {

	bool success = false;
	for (auto itr = this->atomic_basic_blocks.begin(); itr != this->atomic_basic_blocks.end();) {

		if ((*itr).lock() != nullptr && (*itr).lock()->get_seed() == seed) {
			success = true;
			itr = this->atomic_basic_blocks.erase(itr);
		} else {
			++itr;
		}
	}
	if (this->entry_abb.lock() != nullptr && this->entry_abb.lock()->get_seed() == seed)
		this->entry_abb.reset();
	if (this->exit_abb.lock() != nullptr && this->exit_abb.lock()->get_seed() == seed)
		this->exit_abb.reset();

	return success;
}

bool OS::Function::set_definition_vertex(graph::shared_vertex vertex) {

	bool success = false;
	if (this->graph->contain_vertex(vertex)) {
		this->definition_elements.emplace_back(vertex);
		success = true;
	}
	return success;
}

std::set<shared_abb> OS::Function::get_endless_loops() {
	std::set<shared_abb> ret;
	for (const llvm::Loop* loop : loop_info_base) {
		SmallVector<BasicBlock*, 6> vec;
		loop->getExitBlocks(vec);
		if (vec.size() != 0) {
			continue;
		}
		//We have an endless loop
		auto bb = loop->getHeader();
		// TODO currently no way for back mapping
		for (auto abb : get_atomic_basic_blocks()) {
			for (const auto other_bb : *abb->get_BasicBlocks()) {
				if (bb == other_bb) {
					ret.insert(abb);
				}
			}
		}
	}

	return ret;
}

std::vector<graph::shared_vertex> OS::Function::get_definition_vertices() {
	std::vector<graph::shared_vertex> tmp_vector;

	for (auto vertex : this->definition_elements) {
		if (vertex.lock() == nullptr)
			continue;
		else
			tmp_vector.emplace_back(vertex.lock());
	}
	return tmp_vector;
}

void OS::Function::has_syscall(bool flag) { this->syscall_flag = flag; }

bool OS::Function::has_syscall() { return this->syscall_flag; }

void OS::Function::set_function_name(std::string name) { this->function_name = name; }

std::string OS::Function::get_function_name() { return this->function_name; }

void OS::Function::set_definition(function_definition_type type) { this->definition = type; }

function_definition_type OS::Function::get_definition() { return this->definition; }

std::vector<OS::shared_function> OS::Function::get_called_functions() {
	std::vector<OS::shared_function> called_functions;

	for (auto& edge : this->outgoing_edges) {
		if (edge.expired())
			continue;
		shared_vertex vertex = edge.lock()->get_target_vertex();
		// std::cerr << "edge target " << vertex->get_name() << std::endl;
		if (typeid(OS::Function).hash_code() == vertex->get_type()) {
			auto function = std::dynamic_pointer_cast<OS::Function>(vertex);
			called_functions.emplace_back(function);
		}
	}

	// return (this->referenced_functions);
	return called_functions;

} // Gebe std::liste aller Funktionen zurück, die diese Funktion benutzen

std::vector<OS::shared_function> OS::Function::get_calling_functions() {
	std::vector<OS::shared_function> called_functions;

	for (auto& edge : this->ingoing_edges) {

		if (edge.expired())
			continue;
		shared_vertex vertex = edge.lock()->get_start_vertex();
		// std::cerr << "edge target " << vertex->get_name() << std::endl;
		if (vertex != nullptr && typeid(OS::Function).hash_code() == vertex->get_type()) {
			auto function = std::dynamic_pointer_cast<OS::Function>(vertex);
			called_functions.emplace_back(function);
		}
	}

	// return (this->referenced_functions);
	return called_functions;

} // Gebe std::list

bool OS::Function::set_called_function(OS::shared_function function, OS::shared_abb abb) {

	// TODO first call name is used for edge name and check contains
	auto edge =
	    std::make_shared<graph::Edge>(this->graph, abb->get_call_name(), abb->get_parent_function(), function, abb);

	// store the edge in the graph
	this->graph->set_edge(edge);

	// parent function of abb is the self instance
	abb->get_parent_function()->set_outgoing_edge(edge);
	function->set_ingoing_edge(edge);

	return true;
} // Setze Funktion in std::liste aller Funktionen, die diese Funktion benutzen

bool OS::Function::set_start_critical_section_block(llvm::BasicBlock* basic_block) {
	// TODO check if llvm function exists in module
	this->start_critical_section_block = basic_block;
	return true;
}
bool OS::Function::set_end_critical_section_block(llvm::BasicBlock* basic_block) {
	// TODO check if llvm function exists in module
	this->end_critical_section_block = basic_block;
	return true;
}

llvm::BasicBlock* OS::Function::get_start_critical_section_block() { return this->start_critical_section_block; }
llvm::BasicBlock* OS::Function::get_end_critical_section_block() { return this->end_critical_section_block; }

bool OS::Function::has_critical_section() { return this->contains_critical_section; }

void OS::Function::set_critical_section(bool flag) {
	this->contains_critical_section = flag;
	return;
}

bool OS::Function::set_llvm_reference(llvm::Function* function) {

	// TODO check if llvm function exists in module
	this->LLVM_function_reference = function;
	return true;
}

llvm::Function* OS::Function::get_llvm_reference() { return this->LLVM_function_reference; }

void OS::Function::set_atomic_basic_block(OS::shared_abb atomic_basic_block) {
	this->atomic_basic_blocks.emplace_back(atomic_basic_block);
}

void OS::Function::set_atomic_basic_blocks(std::list<OS::shared_abb>* atomic_basic_blocks) {
	this->atomic_basic_blocks.clear();
	for (auto abb : *atomic_basic_blocks) {
		this->atomic_basic_blocks.emplace_back(abb);
	}
}

/*
std::list<graph::shared_vertex> OS::Function::get_atomic_basic_blocks(){
    std::list<graph::shared_vertex> tmp_list;
    for(auto &abb : this->atomic_basic_blocks){
            tmp_list.emplace_back(abb);
    }
    return tmp_list;
}*/

std::list<OS::shared_abb> OS::Function::get_atomic_basic_blocks() {
	// std::cerr << this->atomic_basic_blocks.size() << std::endl;

	std::list<OS::shared_abb> tmp_list;
	for (auto abb : this->atomic_basic_blocks) {
		if (abb.lock() != nullptr)
			tmp_list.emplace_back(abb.lock());
	}

	return tmp_list;
}

std::list<OS::shared_task> OS::Function::get_referenced_tasks() {
	std::list<OS::shared_task> tmp_list;
	for (auto task : this->referenced_tasks) {
		if (task.lock() != nullptr)
			tmp_list.emplace_back(task.lock());
	}
	return tmp_list;
}

bool OS::Function::set_referenced_task(OS::shared_task task) {
	bool success = false;

	if (this->graph->contain_vertex(task)) {
		this->referenced_tasks.emplace_back(task);
		success = true;
	}
	return success;
}

std::list<llvm::Type*> OS::Function::get_argument_types() { return this->argument_types; }

void OS::Function::set_argument_type(llvm::Type* argument) { // Setze Argument des SystemCalls in Argumentenliste
	this->argument_types.emplace_back(argument);
}

void OS::Function::set_return_type(llvm::Type* type) { return_type = type; }

llvm::Type* OS::Function::get_return_type() { return return_type; }

void OS::Function::set_entry_abb(OS::shared_abb abb) { this->entry_abb = abb; }

void OS::Function::set_exit_abb(OS::shared_abb abb) { this->exit_abb = abb; }

OS::shared_abb OS::Function::get_exit_abb() { return this->exit_abb.lock(); }

OS::shared_abb OS::Function::get_entry_abb() { return this->entry_abb.lock(); }

llvm::DominatorTree* OS::Function::get_dominator_tree() { return &this->dominator_tree; }

llvm::PostDominatorTree* OS::Function::get_postdominator_tree() { return &this->postdominator_tree; }

void OS::Function::initialize_dominator_tree(llvm::Function* function) {
	this->dominator_tree.recalculate(*function);
	this->dominator_tree.updateDFSNumbers();
	this->loop_info_base.analyze(this->dominator_tree);
}

void OS::Function::initialize_postdominator_tree(llvm::Function* function) {
	this->postdominator_tree.recalculate(*function);
	this->postdominator_tree.updateDFSNumbers();
}

llvm::LoopInfoBase<llvm::BasicBlock, llvm::Loop>* OS::Function::get_loop_info_base() { return &this->loop_info_base; }

std::ostream& OS::Function::print(std::ostream& stream) const {
	return stream << "Function(" << get_name() << ")";
}

void OS::ABB::set_loop_information(bool flag) { this->in_loop = flag; }

bool OS::ABB::get_loop_information() { return this->in_loop; }

void OS::ABB::set_call_target_instance(size_t target_instance) {
	this->call_target_instances.emplace_back(target_instance);
}

syscall_definition_type OS::ABB::get_syscall_type() { return this->abb_syscall_type; }

void OS::ABB::set_syscall_type(syscall_definition_type type) { this->abb_syscall_type = type; }

std::list<std::size_t>* OS::ABB::get_call_target_instances() { return &(this->call_target_instances); }

call_definition_type OS::ABB::get_call_type() { return this->abb_type; }

void OS::ABB::set_call_type(call_definition_type type) { this->abb_type = type; }

bool OS::ABB::is_critical() { return this->critical_section; }
void OS::ABB::set_critical(bool critical) { this->critical_section = critical; }

std::vector<argument_data> OS::ABB::get_arguments() {

	return this->call.arguments;
	/*
	std::vector<argument_data> argument_list;

	for(auto call :this->calls){
	    if(call.sys_call==false)argument_list.emplace_back(call.arguments);
	}
	//std::cerr << "length: " << this->arguments.size() << std::endl;
	return argument_list;*/
}

std::vector<argument_data> OS::ABB::get_syscall_arguments() {
	std::vector<argument_data> syscall_arguments;

	if (this->call.sys_call == true)
		syscall_arguments = this->call.arguments;
	return syscall_arguments;
}

/*
std::list<std::tuple< std::any,llvm::Type*>> OS::ABB::get_arguments_tmp(){
    return this->arguments;
}*/

void OS::ABB::set_call(call_data* call) { this->call = *call; }

void OS::ABB::set_ABB_successor(OS::shared_abb basicblock) {
	successors.insert(std::pair<size_t, OS::weak_abb>(basicblock->get_seed(), basicblock));
	auto preds = basicblock->get_ABB_predecessors();
	if (preds.find(std::static_pointer_cast<OS::ABB>(shared_from_this())) == preds.end()) {
		basicblock->set_ABB_predecessor(std::static_pointer_cast<OS::ABB>(shared_from_this()));
	}
}

void OS::ABB::set_ABB_predecessor(OS::shared_abb basicblock) {
	predecessors.insert(std::pair<size_t, OS::weak_abb>(basicblock->get_seed(), basicblock));
	auto succs = basicblock->get_ABB_successors();
	if (succs.find(std::static_pointer_cast<OS::ABB>(shared_from_this())) == succs.end()) {
		basicblock->set_ABB_successor(std::static_pointer_cast<OS::ABB>(shared_from_this()));
	}
}

std::set<OS::shared_abb> OS::ABB::get_ABB_successors() {
	std::set<OS::shared_abb> tmp_set;
	for (auto& successor : this->successors) {
		if (successor.second.lock() != nullptr)
			tmp_set.insert(successor.second.lock());
	}
	return tmp_set;
}

OS::shared_abb OS::ABB::get_single_ABB_successor() {
	if (this->successors.size() == 1)
		return (*(this->successors.begin())).second.lock();
	else
		return nullptr;
}

std::set<OS::shared_abb> OS::ABB::get_ABB_predecessors() {

	std::set<OS::shared_abb> tmp_set;
	for (auto predecessor : this->predecessors) {
		if (predecessor.second.lock() != nullptr)
			tmp_set.insert(predecessor.second.lock());
	}
	return tmp_set;
}

bool OS::ABB::set_BasicBlock(llvm::BasicBlock* basic_block) {
	bool success = false;
	if (this->parent_function.lock() != nullptr &&
	    this->parent_function.lock()->get_llvm_reference() == basic_block->getParent()) {
		this->basic_blocks.emplace_back(basic_block);
		success = true;
	}
	return success;
}

std::vector<llvm::BasicBlock*>* OS::ABB::get_BasicBlocks() { return &this->basic_blocks; }

bool OS::ABB::set_parent_function(OS::shared_function function) {

	bool success = false;
	if (this->graph->contain_vertex(function)) {
		success = true;
		this->parent_function = function;
	}
	return success;
}

OS::shared_function OS::ABB::get_parent_function() { return this->parent_function.lock(); }

std::string OS::ABB::get_call_name() {
	std::string call_name = "default";

	if (!this->call.sys_call)
		call_name = this->call.call_name;

	return call_name;
}

llvm::Instruction* OS::ABB::get_call_instruction_reference() {

	if (call.sys_call == false)
		return this->call.call_instruction;

	return nullptr;
}

llvm::Instruction* OS::ABB::get_syscall_instruction_reference() {

	if (call.sys_call == true)
		return this->call.call_instruction;
	return nullptr;
}

bool OS::ABB::convert_call_to_syscall(std::string name) {
	bool success = false;

	if (this->call.call_name == name) {
		this->call.sys_call = true;
		success = true;
	}

	if (success == false) {
		std::cerr << this->get_name() << " could not conver call to syscall" << std::endl;
		abort();
	}

	return success;
}

// helper function to get call argument types of the abb to pyhton
std::list<std::list<size_t>> OS::ABB::get_call_argument_types() {

	std::list<std::list<size_t>> specific_call_argument_types;
	for (auto& argument : this->call.arguments) {
		if (argument.any_list.empty())
			continue;
		std::list<size_t> argument_types;
		for (auto& any_element : argument.any_list) {
			argument_types.emplace_back(any_element.type().hash_code());
		}

		specific_call_argument_types.emplace_back(argument_types);
	}

	return specific_call_argument_types;
}

void OS::ABB::set_called_function(OS::shared_function function, llvm::Instruction* instr) {

	shared_vertex vertex = this->graph->get_vertex(this->seed);
	if (vertex != nullptr) {
		shared_abb abb = std::dynamic_pointer_cast<OS::ABB>(vertex);

		auto edge = std::make_shared<graph::Edge>(this->graph, abb->get_call_name(), abb, function, abb);

		edge->set_instruction_reference(instr);

		// store the edge in the graph
		this->graph->set_edge(edge);

		// parent function of abb is the self instance
		abb->set_outgoing_edge(edge);
		function->set_ingoing_edge(edge);

	} else {
		abort();
	}
}

OS::shared_function OS::ABB::get_called_function() {

	std::vector<OS::shared_function> called_functions;

	for (auto& edge : this->outgoing_edges) {

		if (edge.expired())
			continue;
		shared_vertex vertex = edge.lock()->get_target_vertex();
		// std::cerr << "edge target " << vertex->get_name() << std::endl;
		if (typeid(OS::Function).hash_code() == vertex->get_type()) {
			auto function = std::dynamic_pointer_cast<OS::Function>(vertex);
			called_functions.emplace_back(function);
		}
	}

	if (called_functions.size() > 2) {
		std::cerr << "abb " << this->get_name() << " calls more than one function" << std::endl;
	} else if (called_functions.size() == 0)
		return nullptr;
	else
		return called_functions.front();
}

// append basic blocks to entry abb from abb
bool OS::ABB::append_basic_blocks(shared_abb abb) {

	if (!(this->graph->contain_vertex(abb))) {
		return false;
	}
	for (auto& basic_block : *abb->get_BasicBlocks()) {
		this->set_BasicBlock(basic_block);
	}
	return true;
}

bool OS::ABB::is_mergeable() {

	if (this->get_call_type() == computation)
		return true;
	else
		return false;
	/*
	bool syscall_flag = false;
	for(auto& function : this->get_called_functions()){
	    if(function->has_syscall()){
	        syscall_flag = true;
	        break;
	    }
	}
	//std::cout << syscall_flag << std::endl;
	if(this->abb_type != sys_call  && syscall_flag ==false)return true;
	else{
	    if(this->calls.size() == 0){
	        std::cerr <<
	"ERROR-----------------------------------------------------------------------------------------" << std::endl;
	        this->print_information();
	    }
	    return false;
	}
	*/
}

void OS::ABB::expend_call_sites(shared_abb abb) {

	/*
	//check if the current and the to merged abb have both a syscall
	if(this->syscall_instruction_reference != nullptr && abb->get_syscall_instruction_reference() != nullptr){
	    std::cerr << "ERROR, both abbs, which shall be merged, contain a syscall"<< std::endl;
	    abort();
	}

	//
	if(this->syscall_instruction_reference == nullptr && abb->get_syscall_instruction_reference() != nullptr){
	    this->syscall_instruction_reference = abb->get_syscall_instruction_reference();
	    this->syscall_arguments = *(abb->get_syscall_arguments());
	    this->syscall_name = abb->get_syscall_name();
	}
	*/
	/*
	for(auto call_to_be_joined_abb: *(abb->get_calls())){

	    this->calls.emplace_back(call_to_be_joined_abb);
	}

	for(auto& call_target_instance: *(abb->get_call_target_instances())){

	    this->call_target_instances.emplace_back(call_target_instance);
	}

	//TODO analyze it
	if(abb->get_call_type() != no_call && this->get_call_type() == no_call)this->abb_type = abb->get_call_type();

	if(abb->get_call_type() == sys_call && this->get_call_type() == func_call){
	    std::cerr << "abb merge, syscall abb was merged" << std::endl;
	    this->abb_type = abb->get_call_type();
	}

	auto self_reference = this->graph->get_vertex(this->seed);
	if(self_reference==nullptr){
	    std::cerr << "ERRO , self vertex reference is not stored in graph" << std::endl;
	    abort();
	}
	for(auto& outgoing_edge: abb->get_outgoing_edges()){
	    outgoing_edge->set_start_vertex(self_reference);
	    this->outgoing_edges.emplace_back(outgoing_edge);
	}

	for(auto& ingoing_edge: abb->get_ingoing_edges()){
	    ingoing_edge->set_target_vertex(self_reference);
	    this->ingoing_edges.emplace_back(ingoing_edge);
	}*/
}

call_data OS::ABB::get_call() { return this->call; }

bool OS::ABB::set_syscall_name(std::string call_name) {

	if (this->call.sys_call) {
		this->call.call_name = call_name;
		return true;
	}

	return false;
}

std::string OS::ABB::get_syscall_name() {
	std::string call_name = "default";

	if (this->call.sys_call)
		call_name = this->call.call_name;
	return call_name;
}

llvm::BasicBlock* OS::ABB::get_entry_bb() { return this->entry; }

llvm::BasicBlock* OS::ABB::get_exit_bb() { return this->exit; }

void OS::ABB::remove_successor(shared_abb abb) {
	if (abb != nullptr)
		successors.erase(abb->get_seed());
}

void OS::ABB::remove_predecessor(shared_abb abb) {
	if (abb != nullptr)
		predecessors.erase(abb->get_seed());
}

void OS::ABB::set_entry_bb(llvm::BasicBlock* bb) { this->entry = bb; }

void OS::ABB::set_exit_bb(llvm::BasicBlock* bb) { this->exit = bb; }

void OS::ABB::adapt_exit_bb(shared_abb abb) { this->exit = abb->get_exit_bb(); }

bool OS::ABB::has_single_successor() {
	if (this->successors.size() == 1)
		return true;
	else
		return false;
}

OS::shared_abb OS::ABB::get_postdominator() {

	// std::cerr << "abb " << this->name  << std::endl;

	llvm::BasicBlock* bb = this->exit;

	if (this->parent_function.lock() == nullptr)
		abort();

	llvm::PostDominatorTree* DT = this->parent_function.lock()->get_postdominator_tree();

	if (!DT->isPostDominator()) {
		// std::cerr << "postdominator_tree is not initialized successfully" << std::endl;
		abort();
	}

	std::hash<std::string> hash_fn;
	// get first basic block of the function

	// store coresponding basic block in ABB
	// queue for new created ABBs
	std::queue<shared_abb> queue;

	shared_vertex vertex = this->graph->get_vertex(this->seed);
	if (vertex != nullptr) {
		shared_abb abb = std::dynamic_pointer_cast<OS::ABB>(vertex);
		if (abb)
			queue.push(abb);
	}

	// queue with information, which abbs were already analyzed
	std::vector<size_t> visited_abbs;

	// iterate about the ABB queue
	while (!queue.empty()) {

		// get first element of the queue
		auto abb = queue.front();
		// if(abb->get_entry_bb()==nullptr) std::cerr << "no entry bb " << abb->get_name()  << std::endl;
		if (bb != abb->get_exit_bb() && DT->dominates(abb->get_entry_bb(), bb)) {
			// std::cerr << "postdominator " << abb->get_name()  << std::endl;
			return abb;
		}
		queue.pop();

		bool visited = false;

		size_t seed = hash_fn(abb->get_name());

		for (auto tmp_seed : visited_abbs) {
			if (seed == tmp_seed) {
				visited = true;
				break;
			}
		}
		if (visited)
			continue;
		else
			visited_abbs.push_back(seed);

		// iterate about the successors of the abb
		for (auto successor : abb->get_ABB_successors()) {
			// std::cerr << "successor " << successor->get_name()  << std::endl;
			queue.push(successor);
		}
	}
	// std::cerr << "!!!!!!!!no postdominator!!!!!!!!" << std::endl;
	return nullptr;
}

bool OS::ABB::dominates(shared_abb abb) {
llvm:
	BasicBlock* bb = this->entry;
	if (this->parent_function.lock() == nullptr)
		abort();
	llvm::DominatorTree* DT = this->parent_function.lock()->get_dominator_tree();

	if (DT->properlyDominates(bb, abb->get_entry_bb()))
		return true;
	else
		return false;
}

bool OS::ABB::postdominates(shared_abb abb) {
llvm:
	BasicBlock* bb = this->entry;
	if (this->parent_function.lock() == nullptr)
		abort();
	llvm::PostDominatorTree* PDT = this->parent_function.lock()->get_postdominator_tree();

	if (PDT->properlyDominates(bb, abb->get_entry_bb()))
		return true;
	else
		return false;
}

OS::shared_abb OS::ABB::get_dominator() {

llvm:
	BasicBlock* bb = this->entry;
	if (this->parent_function.lock() == nullptr)
		abort();
	llvm::DominatorTree* DT = this->parent_function.lock()->get_dominator_tree();

	std::hash<std::string> hash_fn;
	// get first basic block of the function

	// store coresponding basic block in ABB
	// queue for new created ABBs
	std::queue<shared_abb> queue;

	shared_vertex vertex = this->graph->get_vertex(this->seed);
	if (vertex != nullptr) {
		shared_abb abb = std::dynamic_pointer_cast<OS::ABB>(vertex);
		if (abb)
			queue.push(abb);
	}

	// queue with information, which abbs were already analyzed
	std::vector<size_t> visited_abbs;

	// iterate about the ABB queue
	while (!queue.empty()) {

		// get first element of the queue
		shared_abb abb = queue.front();

		// TODO remove error that the bb reference is not valid
		// std::string type_str;

		// llvm::raw_string_ostream rso(type_str);
		// abb->get_entry_bb()->getParent()->print(rso);
		// std::cerr << "bb " <<  rso.str()<< std::endl ;

		// if(abb->get_entry_bb() != nullptr)std::cerr << "bb: " <<abb->get_name() << " dominates " << this->name ;
		if (bb != abb->get_entry_bb() && DT->dominates(abb->get_entry_bb(), bb)) {
			// std::cerr << " True" <<  std::endl;
			return abb;
		}
		// std::cerr << " False" <<  std::endl;
		queue.pop();

		bool visited = false;

		size_t seed = hash_fn(abb->get_name());

		for (auto tmp_seed : visited_abbs) {
			if (seed == tmp_seed) {
				visited = true;
				break;
			}
		}
		if (visited)
			continue;
		else
			visited_abbs.push_back(seed);

		// iterate about the successors of the abb
		for (auto predecessor : abb->get_ABB_predecessors()) {
			queue.push(predecessor);
		}
	}
	return nullptr;
}

void OS::ABB::set_start_scheduler_relation(start_scheduler_relation relation) {
	this->start_scheduler_relative_position = relation;
}

start_scheduler_relation OS::ABB::get_start_scheduler_relation() { return this->start_scheduler_relative_position; }

void OS::ABB::set_handler_argument_index(size_t index) { this->syscall_handler_index = index; }

size_t OS::ABB::get_handler_argument_index() { return this->syscall_handler_index; }

void OS::Counter::set_max_allowed_value(unsigned long max_allowed_value) {
	this->max_allowed_value = max_allowed_value;
}

void OS::Counter::set_ticks_per_base(unsigned long ticks_per_base) { this->min_cycle = min_cycle; }

void OS::Counter::set_min_cycle(unsigned long min_cycle) { this->ticks_per_base = ticks_per_base; }

bool OS::Mutex::set_linked_resource(OS::shared_resource resource) {

	bool result = false;
	if (this->graph->contain_vertex(resource)) {
		result = true;
		this->resources.emplace_back(resource);
	}
	return result;
}

bool OS::Mutex::set_resource_property(std::string type, std::string linked_resource) {

	bool result = false;

	switch (str2int(type.c_str())) {

	case str2int("INTERNAL"):
		this->type = internal;
		result = true;
		break;
	case str2int("STANDARD"):
		this->type = standard;
		result = true;
		break;

	case str2int("LINKED"):
		shared_vertex vertex = this->graph->get_vertex(linked_resource);
		shared_vertex self_vertex = this->graph->get_vertex(this->seed);

		shared_resource resource_reference = std::dynamic_pointer_cast<OS::Mutex>(vertex);
		shared_resource self_resource = std::dynamic_pointer_cast<OS::Mutex>(self_vertex);

		if (resource_reference) {
			if (resource_reference->get_resource_type() == linked ||
			    resource_reference->get_resource_type() == standard) {
				this->type = linked;
				result = true;
				this->set_linked_resource(resource_reference);
				resource_reference->set_linked_resource(self_resource);
			}
		}
	}

	return result;
}

void OS::Task::set_priority(unsigned long priority) { 
    this->priority.clear();
    this->priority.emplace_back(priority); 
    
}

void OS::Task::append_priority(unsigned long priority) { this->priority.emplace_back(priority); }

unsigned long OS::Task::get_priority() { 
    
    if(priority.size() == 1) return this->priority.back() ; 
    else return -1;
}

unsigned long OS::Task::get_stacksize() { return this->stacksize; }

void OS::Task::set_constant_priority(bool is_constant) { this->constant_priority = is_constant; }

bool OS::Task::has_constant_priority() { return this->constant_priority; }

void OS::Task::set_stacksize(unsigned long stacksize) { this->stacksize = stacksize; }

bool OS::Task::set_message_reference(std::string message) { return false; }

void OS::Task::set_schedule(bool schedule) {
	this->scheduled = schedule;
}

void OS::Task::set_activation(unsigned long activation) { this->activation = activation; }

void OS::Task::set_autostart(bool autostart) { this->autostart = autostart; }

void OS::Task::set_appmode(std::string app_mode) { this->app_modes.emplace_back(app_mode); }

bool OS::Task::set_resource_reference(std::string resource_name) {
	bool result = false;
	auto resource = this->graph->get_vertex(resource_name);
	if (resource != nullptr) {
		auto resource_cast = std::dynamic_pointer_cast<OS::Mutex>(resource);
		if (resource_cast) {
			this->resources.emplace_back(resource_cast);
			result = true;
		}
	}
	return result;
}

bool OS::Task::set_event_reference(std::string event_name) {
	bool result = false;
	auto event = this->graph->get_vertex(event_name);
	if (event != nullptr) {
		auto event_cast = std::dynamic_pointer_cast<OS::Event>(event);
		if (event_cast) {
			this->events.emplace_back(event_cast);
			result = true;
		}
	}
	return result;
}

bool OS::Task::set_definition_function(std::string function_name) {
	bool result = false;
	std::hash<std::string> hash_fn;
	auto vertex = this->graph->get_vertex(hash_fn(function_name + typeid(OS::Function).name()));

	if (vertex != nullptr) {
		auto function = std::dynamic_pointer_cast<OS::Function>(vertex);

		if (function != nullptr) {
			this->definition_function = function;
			result = true;
		}
	}
	return result;
}

OS::shared_function OS::Task::get_definition_function() { return this->definition_function.lock(); }

void OS::Hook::set_hook_type(hook_type hook) { this->hook = hook; };

bool OS::Hook::set_definition_function(std::string function_name) {

	bool result = false;
	std::hash<std::string> hash_fn;
	auto vertex = this->graph->get_vertex(hash_fn(function_name + typeid(OS::Function).name()));

	if (vertex != nullptr) {
		auto function = std::dynamic_pointer_cast<OS::Function>(vertex);

		if (function != nullptr) {
			this->definition_function = function;
			result = true;
		}
	}

	return result;
}

OS::shared_function OS::Hook::get_definition_function() { return this->definition_function.lock(); }

bool OS::ISR::set_definition_function(std::string function_name) {
	bool result = false;

	std::hash<std::string> hash_fn;
	auto vertex = this->graph->get_vertex(hash_fn(function_name + typeid(OS::Function).name()));

	if (vertex != nullptr) {
		auto function = std::dynamic_pointer_cast<OS::Function>(vertex);

		if (function != nullptr) {

			this->definition_function = function;
			result = true;
		}
	}
	return result;
}

int OS::ISR::get_category() { return this->category; }

OS::shared_function OS::ISR::get_definition_function() { return this->definition_function.lock(); }

bool OS::ISR::set_category(int category) {
	bool result = false;

	if (category == 0 || category == 1) {
		this->category = category;
		result = true;
	}
	return result;
}

void OS::ISR::set_priority(int priority) {
    this->priority = priority;
    return;
}

bool OS::ISR::set_resource_reference(std::string resource_name) {
	bool result = false;
	auto resource = this->graph->get_vertex(resource_name);
	if (resource != nullptr) {
		auto resource_cast = std::dynamic_pointer_cast<OS::Mutex>(resource);
		if (resource_cast) {
			this->resources.emplace_back(resource_cast);
			result = true;
		}
	}
	return result;
}

bool OS::Timer::set_task_reference(std::string task_name) {
	bool result = false;
	auto task = this->graph->get_vertex(task_name);
	if (task != nullptr) {
		auto task_cast = std::dynamic_pointer_cast<OS::Task>(task);
		if (task_cast) {
			this->referenced_task = task_cast;
			result = true;
		}
	}
	return result;
}

bool OS::Timer::set_counter_reference(std::string counter_name) {
	bool result = false;
	auto counter = this->graph->get_vertex(counter_name);
	if (counter != nullptr) {
		auto counter_cast = std::dynamic_pointer_cast<OS::Counter>(counter);
		if (counter_cast) {
			referenced_counter = counter_cast;
			result = true;
		}
	}
	return result;
}

bool OS::Timer::set_event_reference(std::string event_name) {
	bool result = false;
	auto event = this->graph->get_vertex(event_name);
	if (event != nullptr) {
		auto event_cast = std::dynamic_pointer_cast<OS::Event>(event);
		if (event_cast) {
			this->referenced_event = event_cast;
			result = true;
		}
	}
	return result;
}

void OS::Timer::set_alarm_time(unsigned int alarm_time) { this->alarm_time = alarm_time; }

timer_type OS::Timer::get_timer_type() { return this->type; }

void OS::Timer::set_cycle_time(unsigned int cycle_time) { this->cycle_time = cycle_time; }

void OS::Timer::set_appmode(std::string appmode) { this->appmodes.emplace_back(appmode); }

void OS::Timer::set_timer_action_type(timer_action_type type) { this->reaction = type; }

timer_action_type OS::Timer::get_timer_action_type() { return this->reaction; }

void OS::Queue::set_item_size(unsigned long item_size) { this->item_size; }

unsigned long OS::Timer::get_periode() { return this->periode; }

unsigned long OS::Queue::get_item_size() { return this->item_size = item_size; }

unsigned long OS::Queue::get_length() { return this->length; }

void OS::Queue::set_length(unsigned long length) { this->length = length; }

message_property OS::Queue::get_message_property() { return this->property; }

void OS::Queue::set_message_property(message_property property) { this->property = property; }

void OS::Timer::set_timer_id(unsigned long timer_id) { this->timer_id = timer_id; }

void OS::Timer::set_periode(unsigned long periode) { this->periode = periode; }

void OS::Timer::set_timer_type(timer_type type) { this->type = type; }

bool OS::Timer::set_callback_function(std::string function_name) {
	bool result = false;
	std::hash<std::string> hash_fn;
	auto vertex = this->graph->get_vertex(hash_fn(function_name + typeid(OS::Function).name()));

	if (vertex != nullptr) {
		auto function = std::dynamic_pointer_cast<OS::Function>(vertex);

		if (function != nullptr) {

			this->callback_function = function;
			result = true;
		}
	}
	return result;
}

OS::shared_function OS::Timer::get_callback_function() { return this->callback_function.lock(); }

unsigned long OS::Mutex::get_max_count() { return this->max_count; }

unsigned long OS::Mutex::get_initial_count() { return this->initial_count; }

void OS::Mutex::set_resource_type(resource_type type) { this->type = type; }

void OS::Mutex::set_max_count(unsigned long max_count) { this->max_count = max_count; }

void OS::Mutex::set_protocol_type(protocol_type type) { this->protocol = type; }

void OS::Mutex::set_initial_count(unsigned long initial_count) { this->initial_count = initial_count; }

unsigned long OS::Semaphore::get_max_count() { return this->max_count; }

unsigned long OS::Semaphore::get_initial_count() { return this->max_count; }

resource_type OS::Mutex::get_resource_type() { return this->type; }

protocol_type OS::Mutex::get_protocol_type() { return this->protocol; }

void OS::Semaphore::set_max_count(unsigned long max_count) { this->max_count = max_count; }

void OS::Semaphore::set_initial_count(unsigned long initial_count) { this->initial_count = initial_count; }

void OS::Semaphore::set_semaphore_type(semaphore_type type) { this->type = type; }

semaphore_type OS::Semaphore::get_semaphore_type() { return this->type; }

unsigned long OS::QueueSet::get_length() { return this->length; }

void OS::QueueSet::set_queue_element(graph::shared_vertex element) { this->queueset_elements.emplace_back(element); }

void OS::QueueSet::set_length(unsigned long length) { this->length = length; }

std::vector<graph::shared_vertex> OS::QueueSet::get_queueset_elements() {
	std::vector<graph::shared_vertex> tmp_vector;
	for (auto element : this->queueset_elements) {
		if (element.lock() != nullptr)
			tmp_vector.emplace_back(element.lock());
	}
	return tmp_vector;
}

void OS::Buffer::set_buffer_type(buffer_type type) { this->type = type; }

void OS::Buffer::set_buffer_size(unsigned long size) { this->buffer_size = size; }

void OS::Buffer::set_trigger_level(unsigned long level) { this->trigger_level = level; }

buffer_type OS::Buffer::get_buffer_type() { return this->type; }

unsigned long OS::Buffer::get_buffer_size() { return this->buffer_size; }

unsigned long OS::Buffer::get_trigger_level() { return this->trigger_level; }

void OS::CoRoutine::set_priority(unsigned long priority) { this->priority = priority; }

unsigned long OS::CoRoutine::get_priority() { return this->priority; }

void OS::CoRoutine::set_id(unsigned long priority) { this->priority = priority; }

unsigned long OS::CoRoutine::get_id() { return this->priority; }

bool OS::CoRoutine::set_definition_function(std::string function_name) {
	bool result = false;
	std::hash<std::string> hash_fn;
	auto vertex = this->graph->get_vertex(hash_fn(function_name + typeid(OS::Function).name()));

	if (vertex != nullptr) {
		auto function = std::dynamic_pointer_cast<OS::Function>(vertex);

		if (function != nullptr) {

			this->definition_function = function;
			result = true;
		}
	}
	return result;
}

OS::shared_function OS::CoRoutine::get_definition_function() { return this->definition_function.lock(); }

void graph::Graph::print_information() {
	std::string information = "\n------------------------\nGraph:\n";
	information += "Vertices:\n";
	std::cerr << information;
	for (auto& vertex : this->vertices) {
		vertex->print_information();
	}
	std::cerr << "\n------------------------\n\n";
}

void OS::Function::print_information() {
	std::string information = "\n------------------------\nFunction:\n";
	information += "name:" + this->name + "\n";
	information += "function name:" + this->function_name + "\n";
	information += "argument types: ";
	for (auto& argument : this->argument_types) {
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		argument->print(rso);
		information += "\t" + rso.str();
	}
	information += "\n";
	{
		std::string type_str;
		llvm::raw_string_ostream rso(type_str);
		this->return_type->print(rso);
		information += "return type: " + rso.str() + "\n";
	}
	if (contains_critical_section)
		information += "contains critical section: True \n";
	// if(definition_element != nullptr)information += "OS definition instance name:" +
	// this->definition_element->get_name() + "\n";

	if (this->entry_abb.lock() != nullptr)
		information += "first abb: " + this->entry_abb.lock()->get_name() + "\n";
	if (this->exit_abb.lock() != nullptr)
		information += "last abb: " + this->exit_abb.lock()->get_name() + "\n";
	information += "abbs: ";
	std::cerr << information;
	for (auto& abb : this->atomic_basic_blocks) {
		if (abb.lock() != nullptr)
			std::cerr << abb.lock()->get_name() << ", ";
	}

	std::cerr << "\n------------------------\n\n";
}

void OS::ABB::print_information() {
	std::cerr << "\n------------------------\nABB:\n";
	std::cerr << "abb name: " << this->name << "\n";
	std::cerr << "successors: ";
	for (auto& successor : this->successors) {
		if (successor.second.lock() != nullptr)
			std::cerr << "\t" << successor.second.lock()->get_name();
	}

	std::cerr << "\npredecessors: ";
	for (auto& predecessor : this->predecessors) {
		if (predecessor.second.lock() != nullptr)
			std::cerr << "\t" + predecessor.second.lock()->get_name();
	}
	std::cerr << "\n";
	if (this->abb_type != no_call) {

		std::cerr << "syscall: ";
		std::cerr << (this->abb_type);
		std::cerr << "\n";

		std::cerr << "call: " << this->call.call_name << "\n";

		for (auto& data : this->call.arguments) {
			debug_argument(data);
			std::cerr << std::endl;
		}
		std::cerr << "\n";
	}

	std::cerr << "------------------------\n\n";
}

// print methods -------------------------------------------------------------------------------
