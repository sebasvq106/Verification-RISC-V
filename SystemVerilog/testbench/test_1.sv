program testcase (intf_cnt intf);
  
  environment env = new(intf);
  
  initial 
    begin
      $display("Initializing Test #1");
      env.drvr.register();	  // Se cargan registros
      env.drvr.instruction(); // Se generan instrucciones
      #1010;       		      // Simulación dura 1010 unidades de tiempo (ajusta según sea necesario)
  	  $finish;
    end
endprogram