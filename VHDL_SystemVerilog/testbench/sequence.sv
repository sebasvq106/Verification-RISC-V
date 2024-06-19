`ifndef SEQUENCE_SV
`define SEQUENCE_SV
class gen_item_seq extends uvm_sequence;
  
`uvm_object_utils(gen_item_seq)
function new(string name="gen_item_seq");
  super.new(name);
endfunction


virtual task body();
  riscv_item f_item = riscv_item::type_id::create("f_item");
  for (int i = 1; i < f_item.num; i ++) begin
      f_item.index = i;
      start_item(f_item);
      f_item.randomize();
    `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
    f_item.print();
      finish_item(f_item);
  end
  `uvm_info("SEQ", $sformatf("Done generation of items", f_item.num), UVM_LOW)
endtask
endclass
`endif // 