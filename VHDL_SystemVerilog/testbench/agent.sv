// Agente Activo
`ifndef AGENT_SV
`define AGENT_SV
// Angente activo
class riscv_agent_active extends uvm_agent;
  
// lo agrega a la fabrica
`uvm_component_utils(riscv_agent_active)


// contructor
function new(string name="riscv_agent_active", uvm_component parent=null);
    // llama al constructor padre
  super.new(name, parent);
endfunction

// variables uqe va tener el agente activo  

// interface
virtual intf_cnt intf;
// driver
riscv_driver riscv_drv;
// secuenciador UVM con item tipo riscv_item
uvm_sequencer #(riscv_item)	riscv_seqr;
// Monitor wr
riscv_monitor_wr riscv_mntr_wr;


// La fase de contruccion
virtual function void build_phase(uvm_phase phase);
  // llama a la fase contruccion del padre
   super.build_phase(phase);
  
  // verifica si hay base de datos
  if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
  `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
end
  // Crear el driver
  riscv_drv = riscv_driver::type_id::create ("riscv_drv", this); 
  // crea el sequencer con item tipo riscv_item
  riscv_seqr = uvm_sequencer#(riscv_item)::type_id::create("riscv_seqr", this);
  // Crea el monitor wr
  riscv_mntr_wr = riscv_monitor_wr::type_id::create ("riscv_mntr_wr", this);
 
endfunction 


// fase qur va conectar todo
virtual function void connect_phase(uvm_phase phase);
  // llama a la fase de conecion del padre
  super.connect_phase(phase);
  // crear la conexion entre el drive y sequencer
  
  // el driver tiene un puerto llamado seq_item_port 
  // se conecta con el puerto que tiene el sequencer
  // el cual se llama seq_item_export
  riscv_drv.seq_item_port.connect(riscv_seqr.seq_item_export);
endfunction

endclass 





/*               Agente Pasivo              */ 
class riscv_agent_passive extends uvm_agent;
// Lo agrega a la fabrica
`uvm_component_utils(riscv_agent_passive)

// Constructor
function new(string name="riscv_agent_passive", uvm_component parent=null);
   // Constructor padre
   super.new(name, parent);
endfunction

// Declara las clases que va tener

// interface
virtual intf_cnt intf;
// monitor rd
riscv_monitor_rd riscv_mntr_rd;

// Fase de creacion
virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // verifica si tiene la base de datos
    if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
  `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  // crear el monitor tipo rd
    riscv_mntr_rd = riscv_monitor_rd::type_id::create ("fifo_mntr_rd", this);

endfunction

// fase conexion
virtual function void connect_phase(uvm_phase phase);
     // solo tiene un monitor, por lo tanto no hay que conectar
     // nada entre si
     super.connect_phase(phase);
endfunction

endclass
`endif // 