--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:02:18 06/21/2013
-- Design Name:   
-- Module Name:   C:/Users/Cairo/Teste_FPGA/cordic_testbench.vhd
-- Project Name:  Teste_FPGA
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cordic
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use IEEE.math_real.all;
use std.textio.all;
 
ENTITY cordic_testbench IS
END cordic_testbench;
 
ARCHITECTURE behavior OF cordic_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
	 
	constant tam_palavra		:	integer	:= 32;
	constant casas_decimais		:	integer	:=	28;
	constant qtd_tabela			:	integer	:=	25;

 
    COMPONENT cordic
    	generic (
			tam_palavra			:	integer	:= tam_palavra;
			casas_decimais		:	integer	:=	casas_decimais;
			qtd_tabela			:	integer	:=	qtd_tabela
		);
		port(
			clk					:	in		std_logic;
			rst					:	in		std_logic;
			en						:	in		std_logic;
			angulo				:	in		std_logic_vector(tam_palavra - 1 downto 0);
			x_out,y_out,z_out	:	out	std_logic_vector(tam_palavra - 1 downto 0);
			pronto				:	out	std_logic
			
		);
    END COMPONENT;
	 

    

   --Inputs
   signal clk : std_logic := '0';
	signal rst : std_logic := '1';
   signal angulo : std_logic_vector(tam_palavra -1  downto 0) := 
   		std_logic_vector(to_signed(integer((MATH_DEG_TO_RAD*(-180.0))*(2.0**(casas_decimais))),tam_palavra)); 

 	--Outputs
   signal x_out : std_logic_vector(tam_palavra -1 downto 0);
   signal y_out : std_logic_vector(tam_palavra -1 downto 0);
   signal z_out : std_logic_vector(tam_palavra -1 downto 0);
	signal pronto:	std_logic;
	
	--
	signal angulo_real 	: real;
	signal cosseno 			: real;
   signal seno 			: real;
   signal dif_angulo_original 			: real;
   
   signal fim	:	boolean := false;
   
	file resultado : text open write_mode is "resultado.csv";

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN


	angulo_real <=  MATH_RAD_TO_DEG*real(to_integer( signed( angulo )))*(2.0**(-casas_decimais));
	cosseno <= real(to_integer( signed( x_out )))*(2.0**(-casas_decimais));
	seno <= real(to_integer( signed( y_out)))*(2.0**(-casas_decimais));
	dif_angulo_original <=  MATH_RAD_TO_DEG*real(to_integer( signed( z_out )))*(2.0**(-casas_decimais));
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cordic generic map(
			tam_palavra => tam_palavra,
			casas_decimais	=> casas_decimais,
			qtd_tabela =>	qtd_tabela
		)
		port map (
			clk => clk,
			rst => rst,
			en => '1',
			angulo => angulo,
			x_out => x_out,
			y_out => y_out,
			z_out => z_out,
			pronto => pronto
	);

   -- Clock process definitions
   clk_process :process
   begin
   		if fim=true then
   			wait;
   		end if;
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
		
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		wait for 100 ns;	
		wait for clk_period*10;
		-- insert stimulus here
		wait for clk_period;
		rst<='0';
      wait;
   end process;
	
	gerador_de_angulos : process
		variable contador : real := -179.5;
		variable res_linha : line;
		
	begin
		while fim=false loop
			wait until pronto='1';
			
			if rst='0' and contador <=180.0 then
				write (res_linha, real'image(angulo_real) & "; " & real'image(cosseno) & "; " & real'image(seno));
    			writeline (resultado, res_linha);
				angulo <= std_logic_vector(to_signed(integer((MATH_DEG_TO_RAD*contador)*(2.0**(casas_decimais))),tam_palavra)); 
					contador := contador +0.5;
			elsif contador > 180.0 then
				file_close(resultado);
				fim <= true;
				wait;
			end if;
			
		end loop;
		
	end process;
	
	
	
	

END;
