// Driver
`ifndef DRIVER_SV
`define DRIVER_SV
// Driver del RiscV

class riscv_driver extends uvm_driver #(riscv_item);
// Agrega a la Fabrica
`uvm_component_utils (riscv_driver)

int i;


// Constructor
 function new (string name = "fifo_driver", uvm_component parent = null);
     // Llama al constructor padre
     super.new (name, parent);
 endfunction

  // declarala las variables que va tener

// interface
  virtual intf_cnt intf;


// Fase de construcion
  virtual function void build_phase (uvm_phase phase);
    
     super.build_phase (phase);
    
     // verifica si tiene base de datos
     if(uvm_config_db #(virtual intf_cnt)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
     `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
     end
 endfunction
 

 // Fase de conexion
 virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
 endfunction


 // fase de run
 virtual task run_phase(uvm_phase phase);
    // Llama a la fase run del padre
    super.run_phase(phase);
    forever begin
       // declara una variable del tipo riscv_item
       riscv_item f_item;
       // mensaje que esta esperando un item del tipo riscv_item
       `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
       // obtiene el item tipo riscv_item del secuenciador
       seq_item_port.get_next_item(f_item);
       fork
           // si index es menor a 7, manda intrucciones del tipo ADDI
         if (f_item.index < 30) begin 
           register(f_item);
         end else begin
            instruction(f_item);
         end
      join
         // Terminado
         seq_item_port.item_done();
      end
 endtask


// Task para darle reset al risc v
virtual task reset();
  
  @(intf.tb_clk);
  intf.reset = 1;
  #35 intf.reset = 0;
  top_hdl.riscV.dp.instr_mem.Inst_mem[0] = 32'h00000000;
endtask




// Task para mandar los ADDI
virtual task register(riscv_item f_item);

    begin
      `uvm_info("DRV", $sformatf("Envio registro"), UVM_LOW)
      @ ( posedge intf.tb_clk); 
      if(f_item.index == 1) begin
        top_hdl.riscV.dp.instr_mem.Inst_mem[f_item.index] = 32'h00007033;
      end
      else begin 
        top_hdl.riscV.dp.instr_mem.Inst_mem[f_item.index] = f_item.rand_register;
        intf.instruction_queue = f_item.rand_register;
           
      end
      
      
    end
endtask
  

  // Generador de instrucciones    
virtual task instruction(riscv_item f_item);

    begin
    `uvm_info("DRV", $sformatf("Envio instruciones"), UVM_LOW)
    @ ( posedge intf.tb_clk);  
    top_hdl.riscV.dp.instr_mem.Inst_mem[f_item.index] = f_item.rand_instruction;
    intf.instruction_queue = f_item.rand_instruction;
      i = f_item.index;
    end
endtask
         

endclass
`endif // 