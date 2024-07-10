`ifndef MONITOR_SV
`define MONITOR_SV
// Monitor del RiscV

class riscv_monitor extends uvm_monitor;
// Se agrega a la fabrica
`uvm_component_utils (riscv_monitor)

// variables

// interface
virtual intf_cnt intf;
// Analisis de UVM, analisa los tipos riscv_item que se envian
uvm_analysis_port #(riscv_item)   mon_analysis_port;
 


// Constructor
function new (string name, uvm_component parent= null);
    super.new (name, parent);
endfunction

// Fase de creacion
virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);

    // Crea el Analisis UVM
    mon_analysis_port = new ("mon_analysis_port", this);
  
    // Verifica si hay base de datos
  if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
     `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
endfunction


  //  Fase de Run
  virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);
 endtask

  // funcion check_protocol
  virtual function void check_protocol ();
    // Function to check basic protocol specs
 endfunction
endclass





/*             Monitor Wr del tipo Monitor base          */
class riscv_monitor_wr extends riscv_monitor;
// se agrega a la fabrica
`uvm_component_utils (riscv_monitor_wr)

 // constructor
 function new (string name, uvm_component parent= null);
    super.new (name, parent);
 endfunction


 // fase de creacion
 virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
 endfunction

// fase de run
 virtual task run_phase (uvm_phase phase);
   // crea un riscv_item (data_obj)
    riscv_item  data_obj = riscv_item::type_id::create ("data_obj", this);
     
    forever begin
          // cada vez que intf.instruction_queue cambie
      @(posedge intf.tb_clk);  
          // guarda la intruccion y la almacena en instruction_send
         data_obj.instruction_send = intf.instruction_queue;
      
      
          // escribe en el puerto mon_analysis_port el data_obj
          // este puerto se conecta al scoreboard
          // Para que el scoreboard tenga la instruccion que esta ejecutando el dut
           mon_analysis_port.write (data_obj);
      end
 endtask

endclass





/*             Monitor Wr del tipo Monitor base          */
class riscv_monitor_rd extends riscv_monitor;
// se agrega a la fabrica
`uvm_component_utils (riscv_monitor_rd)

 // constructor
 function new (string name, uvm_component parent= null);
    super.new (name, parent);
 endfunction

 // fase de creacion
 virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
 endfunction

 // fase de run
 virtual task run_phase (uvm_phase phase);
    // crea un riscv_item
    riscv_item  data_obj = riscv_item::type_id::create ("data_obj", this);
    forever begin
      // En cada flanco negativo se le manda un copia de los reg del dut
      // al scoreboard
      
      // or negedge intf.tb_clk posedge posedge 
      @(intf.cambio)
      //if (intf.tb_clk==1) begin
      data_obj.reg_file_send = intf.reg_file_monitor;
      //`uvm_info ("Ojo", $sformatf("registro a ver = %d", intf.reg_file_monitor[1]), UVM_MEDIUM)
       // Escribe en el puerto el data_obj, que va tener una 
       // copia de los reg del dut
       mon_analysis_port.write (data_obj);
      end
    //end
 endtask

endclass
`endif // 