class environment;
  
	driver drvr;
	virtual intf_cnt intf;
 	monitor mntr;
	scoreboard sb;
  
 	function new(virtual intf_cnt intf);
      
    	$display("Creating environment");
    	this.intf = intf;
      	sb = new();
      	drvr = new(intf, sb);
      	mntr = new(intf, sb);
      	fork 
     		mntr.check();
    	join_none

	endfunction
  
endclass