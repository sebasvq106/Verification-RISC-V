`ifndef COVERAGE_SV
`define COVERAGE_SV
class funct_coverage extends uvm_component;

  `uvm_component_utils(funct_coverage)
  
  
  // Tipo Lui
  covergroup instruction_LUI;
    //cover de la instruccion
  	opcode_LUI: coverpoint intf.instruction_queue[6:0] {
      bins opcode = {7'b0110111};
    }
    // cover sobre los registros
    rd: coverpoint intf.instruction_queue[11:7] iff (intf.instruction_queue[6:0] == 7'b0110111) {
      bins reg_destino[] = {[0:31]};
    }
  endgroup

  ///////////////////////////////////////////////////////////////////////////////////////////////
  
    
  // Tipo R   
      
  covergroup instruction_R;
    
    opcode_R: coverpoint intf.instruction_queue[6:0] {
      bins opcode = {7'b0110011};
    }
    
    // destino
    rd: coverpoint intf.instruction_queue[11:7] iff (intf.instruction_queue[6:0] == 7'b0110011) {
      bins reg_destino[] = {[0:31]};
    }
    
    // operaciones menos sub
    operaciones: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0110011 && intf.instruction_queue[31:25] ==  7'b0000000) {
      bins operaciones_menos_sub[] = {[0:7]};
    }
    
    // operacion sub
    sub: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0110011 && intf.instruction_queue[31:25] == 7'b0100000 ) {
      bins operacion_sub[] = {3'b000};
    }
    
    // secuencia ADD -> OR ->  STL -> XOR -> AND 
    secuencia: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0110011 && intf.instruction_queue[31:25] == 7'b000000 ) {
      bins operacion_sub[] = (0=>5=>2=>4=>7);
    }
    
  endgroup
  
  
  ///////////////////////////////////////////////////////////////////////////////////////
  
  // Tipo I
  
  covergroup instruction_I;
    
    
    opcode_I: coverpoint intf.instruction_queue[6:0] {
      bins opcode = {7'b0010011};
    }
    
    // destino
    rd: coverpoint intf.instruction_queue[11:7] iff (intf.instruction_queue[6:0] == 7'b0010011) {
      bins reg_destino[] = {[0:31]};
    }
    
    // operaciones 
    operaciones: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0010011) {
      bins operaciones_menos_sub[] = {[0:7]};
    }
    
    // secuencia ADDI -> 
    secuencia: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0010011) {
      bins operacion_sub[] = (0=>6=>7=>3=>4);
    }
    
    
  endgroup
  
 /////////////////////////////////////////////////////////////////////////////////////////////

  
 // Tipo Load
  
  covergroup instruction_load;
    opcode_load: coverpoint intf.instruction_queue[6:0] {
      bins opcode = {7'b0000011};
    }
    
    // destino
    rd: coverpoint intf.instruction_queue[11:7] iff (intf.instruction_queue[6:0] == 7'b0000011) {
      bins reg_destino[] = {[0:31]};
    }
    
    // operaciones de load
  operaciones: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0000011) {
    bins operaciones_load[] = {3'b000, 3'b001, 3'b010, 3'b100, 3'b101}; // lb, lh, lw, lbu, lhu
  }
    
   // secuencia
   secuencia: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0000011) {
     bins operacion_load[] = (2=>0=>4=>1=>2); // lw, lb, lbu, lh, lw
    }
endgroup

  ///////////////////////////////////////////////////////////////////////////////////////
  
  // Tipo Store
  
  covergroup instruction_store;
    opcode_store: coverpoint intf.instruction_queue[6:0] {
      bins opcode = {7'b0100011};
    }
    
    // operaciones de store
  operaciones: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0100011) {
    bins operaciones_load[] = {[0:2]}; // sb, sh, sw
  }
    
     // secuencia
   secuencia: coverpoint intf.instruction_queue[14:12] iff (intf.instruction_queue[6:0] == 7'b0100011) {
     bins operacion_store[] = (1=>2=>0=>0=>2); // sh, sw, sb, sb, sw
    }

  endgroup

  ///////////////////////////////////////////////////////////////////////////////////////
  
  // Combinadas
   
 covergroup instruction_totales;
     opcodes: coverpoint intf.instruction_queue[6:0] {
        bins opcode_0110011 = {7'b0110011};
        bins opcode_0010011 = {7'b0010011};
        bins opcode_0000011 = {7'b0000011};
        bins opcode_0100011 = {7'b0100011};
        bins opcode_0110111 = {7'b0110111};
  }
   // secuencia
   secuencia: coverpoint intf.instruction_queue[6:0] {
     bins operacion_store[] = (7'b0010011=>7'b0010011=>7'b0100011=>7'b0110011=>7'b0110111=>7'b0000011); // addi, addi, sw, sll, lui, lb
    }
endgroup

  ///////////////////////////////////////////////////////////////////////////////////////
  

  function new (string name = "funct_coverage", uvm_component parent = null);
    super.new(name, parent);
    instruction_R = new(); 		 // Inicializa el covergroup instruction_R
    instruction_I = new();
    instruction_load = new();   // Inicializa el covergroup instruction_load
    instruction_store = new();  // Inicializa el covergroup instruction_load
    instruction_LUI = new();    // Inicializa el covergroup de LUI
    instruction_totales = new();
  endfunction
  
  virtual intf_cnt intf;

  /////////////////////////////////////////////////////////////////////////////////////////////
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    // verifica si tiene base de datos
    if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
  endfunction
  
  /////////////////////////////////////////////////////////////////////////////////////////////////
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(posedge intf.tb_clk) begin
        instruction_R.sample();
        instruction_I.sample();
        instruction_load.sample();
        instruction_store.sample();
        instruction_LUI.sample();
        instruction_totales.sample();
      end
    end
  endtask  

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    // Report coverage
	
    // Tipo R
    $display("Instruction type R Coverage Overall: %3.2f%% coverage achieved.", instruction_R.get_coverage());
    $display("Instruction type R Coverage opcode_R: %3.2f%% coverage achieved.", instruction_R.opcode_R.get_coverage());
    $display("Instruction type R Coverage reg_destino: %3.2f%% coverage achieved.", instruction_R.rd.get_coverage());
    $display("Instruction type R Coverage operaciones: %3.2f%% coverage achieved.", instruction_R.operaciones.get_coverage());
    $display("Instruction type R Coverage operacion_sub: %3.2f%% coverage achieved.", instruction_R.sub.get_coverage());
    $display("secuencia  type R Coverage: %3.2f%% coverage achieved.", instruction_R.secuencia.get_coverage());
    
    
    $display("\n"); // Agrega un punto y coma al final de esta línea
///////////////////////////////////////////////////////////////////////////
    
    // Tipo I
    $display("Instruction  type I Coverage Overall: %3.2f%% coverage achieved.", instruction_I.get_coverage());
    $display("Instruction Coverage opcode_I: %3.2f%% coverage achieved.", instruction_I.opcode_I.get_coverage());
    $display("Instruction Coverage reg_destino: %3.2f%% coverage achieved.", instruction_I.rd.get_coverage());
    $display("Instruction Coverage operaciones: %3.2f%% coverage achieved.", instruction_I.operaciones.get_coverage());
    $display("secuencia  type I Coverage: %3.2f%% coverage achieved.", instruction_I.secuencia.get_coverage());
////////////////////////////////////////////////////////////////////////////
    
    
  $display("\n"); // Agrega un punto y coma al final de esta línea
    
    // Tipo Load
    $display("Instrucciones tipo LOAD:");
    $display("Instruction Coverage Overall: %3.2f%% coverage achieved.", instruction_load.get_coverage());
    $display("Instruction Coverage opcode_load: %3.2f%% coverage achieved.", instruction_load.opcode_load.get_coverage());
    $display("Instruction Coverage reg_destino: %3.2f%% coverage achieved.", instruction_load.rd.get_coverage());
    $display("Instruction Coverage operaciones: %3.2f%% coverage achieved.", instruction_load.operaciones.get_coverage());
    $display("Instruction Coverage secuencia: %3.2f%% coverage achieved.", instruction_load.secuencia.get_coverage());
    $display("\n"); // Agrega un punto y coma al final de esta línea
    
    // Tipo Store
    $display("Instrucciones tipo STORE:");
    $display("Instruction Coverage Overall: %3.2f%% coverage achieved.", instruction_store.get_coverage());
    $display("Instruction Coverage opcode_store: %3.2f%% coverage achieved.", instruction_store.opcode_store.get_coverage());
    $display("Instruction Coverage operaciones: %3.2f%% coverage achieved.", instruction_store.operaciones.get_coverage());
    $display("Instruction Coverage secuencia: %3.2f%% coverage achieved.", instruction_store.secuencia.get_coverage());
     $display("\n"); // Agrega un punto y coma al final de esta línea
    
    //LUI
    $display("Instruccion tipo LUI:");
    $display("Instruction Coverage Overall: %3.2f%% coverage achieved.", instruction_LUI.get_coverage());
    $display("Instruction Coverage LUI instruction: %3.2f%% coverage achieved.", instruction_LUI.opcode_LUI.get_coverage());
    $display("Instruction Coverage reg_destino: %3.2f%% coverage achieved.", instruction_LUI.rd.get_coverage());
    $display("\n"); // Agrega un punto y coma al final de esta línea
    
    //Combinada
    $display("Instruccion tipo Combinadas:");
    $display("Instruction Coverage Overall: %3.2f%% coverage achieved.", instruction_totales.get_coverage());
    $display("Instruction Coverage Opcodes: %3.2f%% coverage achieved.", instruction_totales.opcodes.get_coverage());
    $display("Instruction Coverage secuencia: %3.2f%% coverage achieved.", instruction_totales.secuencia.get_coverage());
    $display("\n"); // Agrega un punto y coma al final de esta línea
  endfunction

endclass

`endif // 