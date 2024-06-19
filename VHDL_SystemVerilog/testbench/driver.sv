// Driver
`ifndef DRIVER_SV
`define DRIVER_SV
// Driver del RiscV

class riscv_driver extends uvm_driver #(riscv_item);
  
// Agrega a la Fabrica
`uvm_component_utils (riscv_driver)

// Constructor
 function new (string name = "fifo_driver", uvm_component parent = null);
     super.new (name, parent);
 endfunction

  virtual intf_cnt intf;

// Fase de construcion
  virtual function void build_phase (uvm_phase phase);
    
     super.build_phase (phase);
    
     if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
     `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
     end
 endfunction
 

 // Fase de conexion
 virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
 endfunction


 // Fase de run
 virtual task run_phase(uvm_phase phase);
   
    super.run_phase(phase);
    forever begin
       riscv_item f_item;  // Declara una variable del tipo riscv_item
       `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
       seq_item_port.get_next_item(f_item);
       fork
         if (f_item.index < 32) begin
              register(f_item);
          end else begin
              instruction(f_item);
          end
      join
         seq_item_port.item_done();
      end
 endtask


// Task Reset
virtual task reset();
  @(intf.tb_clk);
  intf.reset = 1;
  #35 intf.reset = 0;
  top_hdl.riscV.dp.instr_mem.Inst_mem[0] = 32'h00000000;
endtask

// Task Register
virtual task register(riscv_item f_item);
    begin
   
      // La primera instruccion carga un cero
      if(f_item.index == 1) begin
        top_hdl.riscV.dp.instr_mem.Inst_mem[f_item.index] = 32'h00007033;
      end
      else begin
        
      // Se calcula el offset
      int offset = f_item.index - 1;
      logic [4:0] offset_bits = offset[4:0];
      
      // Se envian los registros
      top_hdl.riscV.dp.instr_mem.Inst_mem[f_item.index] = {f_item.inm12, f_item.rs1, f_item.funct3_rg, offset_bits , f_item.opcode_rg};
      intf.instruction_queue = {f_item.inm12, f_item.rs1, f_item.funct3_rg, offset_bits, f_item.opcode_rg};
           
      end
      @(posedge intf.tb_clk);
      
    end
endtask
  

  // Task Instruction    
virtual task instruction(riscv_item f_item);
    begin
    
    // Se envian las instrucciones
    top_hdl.riscV.dp.instr_mem.Inst_mem[f_item.index] = f_item.rand_instruction;
    intf.instruction_queue = f_item.rand_instruction;  
    @ (posedge intf.tb_clk);
    
    end
endtask
            

endclass
`endif // 