-------------------------------------------------------
--! @file
--! @brief CORDIC iterativa em VHDL
--! @author Cairo Caplan <cairo@cbpf.br>
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity cordic is
	generic (
		tam_palavra			:	integer	:= 32;
		casas_decimais		:	integer	:=	20;
		qtd_tabela			:	integer	:=	20
	);
	port(
		clk					:	in		std_logic;
		rst					:	in		std_logic;
		en						:	in		std_logic;
		angulo				:	in		std_logic_vector(tam_palavra - 1 downto 0);
		x_out,y_out,z_out	:	out	std_logic_vector(tam_palavra - 1 downto 0);
		pronto				:	out	std_logic
	);

end cordic;

architecture Behavioral of cordic is


	--! @defgroup constantes Constantes auxiliares
	--! @{
	constant k					:	signed(tam_palavra - 1 downto 0) := to_signed(INTEGER(0.6073*(2.0**casas_decimais)),tam_palavra);
	constant max_iteracoes	:	unsigned(4 downto 0) := to_unsigned(10,5);
	
	type	tabela_atan_t	is	array (qtd_tabela -1 downto 0) of signed(tam_palavra - 1 downto 0);
	
	function gera_tabela_atan (qtd : integer) return tabela_atan_t is 
		variable tabela_calculada	:	tabela_atan_t := (others=>(others=>'0'));
	begin
		for i in 0 to qtd -1 loop
			tabela_calculada(i) := to_signed(INTEGER(arctan(2.0**(-i))*(2.0**casas_decimais)),tam_palavra);
		end loop;
	  return tabela_calculada;
	end gera_tabela_atan;
	
	constant	tabela_atan	:	tabela_atan_t := gera_tabela_atan(qtd_tabela);
	--! @}
	
	
	
	signal 	x,y,z				:	signed(tam_palavra - 1 downto 0);
	signal 	x_p,y_p,z_p			:	signed(tam_palavra - 1 downto 0);
	signal 	Dx,Dy				:	signed(tam_palavra - 1 downto 0);
	signal 	cont_iter			:	natural range 0 to qtd_tabela;
	signal	Zmsb				:	std_logic;
	signal	angulo_usado		:	signed(tam_palavra - 1 downto 0);
	signal	angulo_ant			:	signed(tam_palavra - 1 downto 0);
	
	signal inverte_valores		:	std_logic;
	signal inverte_valores_buf	:	std_logic;
	
	signal	pronto_int			:	std_logic:='1';
	
	--! @defgroup constantes Constantes auxiliares
	--! @{
	--	signal	x_db,y_db,z_db,atan_db,z_p_db,x_p_db,y_p_db,Dx_db,Dy_db			:	real;
	--	
	--	type	atan_db_t	is	array (qtd_tabela -1 downto 0) of real;
	--	
	--	function gera_tabela_atan_db (qtd : integer) return atan_db_t is 
	--		variable i 						:	integer;
	--		variable tabela_atan_db	:	atan_db_t;
	--	begin
	--		for i in 0 to qtd -1 loop
	--			
	--			tabela_atan_db(i) := MATH_RAD_TO_DEG*arctan(2.0**(-i));
	--			
	--		end loop;
	--	  return tabela_atan_db;
	--	end gera_tabela_atan_db;
	--
	--	signal tabela_atan_db		:	atan_db_t;
	--! @}
	

begin
	
	correcao_dos_quadrantes : process (angulo) is
	begin
		--Se estiver no segundo quadrante
		if	signed(angulo) > to_signed(integer((MATH_DEG_TO_RAD*90.0)*(2.0**(casas_decimais))),tam_palavra) and
			signed(angulo) <= to_signed(integer((MATH_DEG_TO_RAD*180.0)*(2.0**(casas_decimais))),tam_palavra) then
			--traga-o para o quarto quadrante subtraindo 180 graus
			angulo_usado <= signed(angulo) - to_signed(integer((MATH_DEG_TO_RAD*180.0)*(2.0**(casas_decimais))),tam_palavra);
			inverte_valores <= '1';
			
		--Se estiver no terceiro quadrante	
		elsif signed(angulo) < to_signed(integer((MATH_DEG_TO_RAD*(-90.0))*(2.0**(casas_decimais))),tam_palavra) and
			signed(angulo) >= to_signed(integer((MATH_DEG_TO_RAD*(-180.0))*(2.0**(casas_decimais))),tam_palavra) then
			--traga-o para o primeiro quadrante somando 180 graus
			angulo_usado <= signed(angulo) + to_signed(integer((MATH_DEG_TO_RAD*180.0)*(2.0**(casas_decimais))),tam_palavra);
			inverte_valores <= '1';
			
		-- Senão, não altere o valor
		else
			angulo_usado <= signed(angulo);
			inverte_valores <= '0';
		end if;	
	end process correcao_dos_quadrantes;
	

cordic_iterativa	:	process(clk)
	
	begin
	
	if rising_edge(clk) then
		if rst = '1' or (pronto_int='1' and angulo_usado /= angulo_ant) then
			x <= k;
			y <= (others=>'0');
			z <= signed(angulo_usado);
			cont_iter <=0;
			if pronto_int='1' and angulo_usado /= angulo_ant then
				pronto_int<='0';
				angulo_ant <= angulo_usado;
				inverte_valores_buf <= inverte_valores;
			else 
				pronto_int <= '1';
				x_out <= (others=>'0');
				y_out <= (others=>'0');
				z_out <= (others=>'0');
			end if;
		elsif en = '1' then
			if cont_iter<=max_iteracoes then
				x <= x_p;
				y <= y_p;
				z <= z_p;
				cont_iter <= cont_iter +1;
			end if;
			if cont_iter = max_iteracoes - 1 then
				pronto_int <= '1';
				if inverte_valores_buf='1' then
					x_out <= std_logic_vector(-x);
					y_out <= std_logic_vector(-y);
				else
					x_out <= std_logic_vector(x);
					y_out <= std_logic_vector(y);
				end if;
				z_out <= std_logic_vector(z);
			else
				pronto_int<='0';
			end if;
		end if;
	end if;
	end process;
	
	pronto <= pronto_int;
	
	Dy <= shift_right(y,cont_iter);
	Dx <= shift_right(x,cont_iter);
	
	
	Zmsb <= z(z'high);
	
	with Zmsb select
		x_p <= x - Dy when '0', x + Dy when others;
		
	with Zmsb select
		y_p <= y + Dx when '0', y - Dx when others;
		
	with Zmsb select
		z_p <= z - tabela_atan(cont_iter) when '0', z + tabela_atan(cont_iter) when others;
	

	--! Secao de Depuracao
--	x_db <= real(to_integer( signed( x )))*(2.0**(-casas_decimais));
--	x_p_db <= real(to_integer( signed( x_p )))*(2.0**(-casas_decimais));
--	Dx_db <= real(to_integer( signed( Dx )))*(2.0**(-casas_decimais));
--	
--	y_db <= real(to_integer( signed( y )))*(2.0**(-casas_decimais));
--	y_p_db <= real(to_integer( signed( y_p )))*(2.0**(-casas_decimais));
--	Dy_db <= real(to_integer( signed( Dy )))*(2.0**(-casas_decimais));
--	
--	
--	z_db <= MATH_RAD_TO_DEG*real(to_integer( signed( z )))*(2.0**(-casas_decimais));
--	z_p_db <= MATH_RAD_TO_DEG*real(to_integer( signed( z_p )))*(2.0**(-casas_decimais));
--	atan_db <= MATH_RAD_TO_DEG*real(to_integer( signed( tabela_atan(count) )))*(2.0**(-casas_decimais));
--	tabela_atan_db <= gera_tabela_atan_db(qtd_tabela);

	
	
	
	
	
	


end Behavioral;



