`ifndef ENV_SV
`define ENV_SV
// Env del RiscV

class riscv_env extends uvm_env;
  
// Agrega a la fabrica
`uvm_component_utils(riscv_env)

// Constructor
function new (string name = "riscv_env", uvm_component parent = null);
  super.new (name, parent);
endfunction

// Interface
virtual intf_cnt intf;
// Agente activo
riscv_agent_active riscv_ag_active;
// Agente passive
riscv_agent_passive riscv_ag_passive;
// Scoreboard
riscv_scoreboard riscv_sb;

// Fase de creacion
virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
    `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
  end
  
  // Crea agente activo
  riscv_ag_active = riscv_agent_active::type_id::create ("riscv_ag_active", this);
  // Crea agente passive
  riscv_ag_passive = riscv_agent_passive::type_id::create ("riscv_ag_passive", this);
  // Crea scoreboard
  riscv_sb = riscv_scoreboard::type_id::create ("riscv_sb", this); 
 
  uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
  print();

endfunction

// Fase de conexion
virtual function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // Conecta el monitor wr con el scoreboard
  riscv_ag_active.riscv_mntr_wr.mon_analysis_port.connect(riscv_sb.riscv_drv);
  // Conecta el monitor rd con el scoreboard
  riscv_ag_passive.riscv_mntr_rd.mon_analysis_port.connect(riscv_sb.riscv_mon);
endfunction

endclass
`endif // 