/*//----
This example has a reference to www.learnuvmverification.com. 
txn is a uvm_sequence_item having 3 properties.
produce is uvm_component which generates 5 transaction.
consumer which is also uvm_component receives transaction
producer and conumers are connected via put() port. 
Connection can be done via get() port also.
Environment has producer and consumer instabtiated.

how to run in questa
1. vlib work
2. vmap work work
3. vlog port_imp.sv
4. vsim -c -novopt port_imp
//-c for noconsole
5. run -all
6. See transcript for output
*/

`include "uvm_macros.svh"
import uvm_pkg::*;
class txn extends uvm_sequence_item;
//	`uvm_object_utils(txn) //FIXME-if i register 'txn' using this line- i wasn'y able to print fields. why?
	//Lets have three Fields and randomize
	typedef enum {READ,WRITE} rd_wr;
	rand bit[7:0] addr;
	rand byte data;
	rand rd_wr mode;
	function new(string name="txn");
	super.new(name);
	//mode=mode'($urandom_range(0,1)); // this line throws syntax error. check
	endfunction
	constraint addr_c {
		addr <100; addr>10;
	}

	constraint data_c {
		data >100; data <500;
	}

	constraint rd_wr_c {
	//	mode(0)!=mode(1);
	}

//	register fields to factory
	`uvm_object_utils_begin(txn)
	`uvm_field_enum(rd_wr,mode,UVM_DEC)
	`uvm_field_int(addr,UVM_DEC)
	`uvm_field_int(data,UVM_DEC)
	`uvm_object_utils_end

endclass:txn

class producer extends uvm_component;
	`uvm_component_utils(producer)
	uvm_blocking_put_port #(txn) put_port;
	function new(string name, uvm_component parent);
		super.new(name,parent);
		put_port=new ("put_port",this);
	endfunction
	task run_phase(uvm_phase phase);
	for (int packet = 0; packet<5; packet++) begin	// you dont have to for loop at consumer.
		txn txn_;
		txn_ = txn::type_id::create("txn_",this);
		assert(txn_.randomize()) else $display("fatal error");
		$display(" Printing T at producer");
	//	t.print();
	/*	case(t.mode)
			t.READ :$display("At Producer: Read transaction");
			t.WRITE:$display("At Producer: WRITE transaction");
		endcase; */
		put_port.put(txn_);// put definition will be implemented in consumer
	end
	endtask:run_phase
endclass:producer

class consumer extends uvm_component;
	`uvm_component_utils(consumer)
	uvm_blocking_put_imp #(txn,consumer) put_imp;
	function new(string name, uvm_component parent);
		super.new(name,parent);
		put_imp=new("put_imp",this);//  put method definition here
	endfunction
	task put(txn t); // put is standard call
		t.print(); // print() is standard uvm call 
	/*	case(t.mode)
			t.READ :$display("At consumer: Read transaction");
			t.WRITE:$display("At consumer: WRITE transaction");
		endcase*/
	endtask: put
endclass:consumer

// Environment
class environment extends uvm_env;
	producer prod;
	consumer cons;
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		prod = producer::type_id::create("prod",this);
		cons = consumer::type_id::create("cons",this);
	endfunction: build_phase
	function void connect_phase(uvm_phase phase);
		prod.put_port.connect(cons.put_imp);
	endfunction: connect_phase
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		#1000;
		phase.drop_objection(this);
	endtask: run_phase
	function new(string name="environment");
		super.new(name);
	endfunction
endclass:environment

module port_imp;
	environment env;
	initial begin
		env=new();
		run_test();
	end
endmodule:port_imp

























