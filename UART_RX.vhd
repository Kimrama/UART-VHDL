library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RX is
    Port ( CLK : in STD_LOGIC;            
           RX : in STD_LOGIC;             
           RX_DATA : out STD_LOGIC_VECTOR (7 downto 0); 
           RX_READY : out STD_LOGIC;       
           LOAD_PULSE : out STD_LOGIC      -- 
           );
end UART_RX;

architecture Behavioral of UART_RX is
    signal rx_shift_reg : STD_LOGIC_VECTOR (8 downto 0) := (others => '1');  
    signal bit_count : integer := 0;   
    signal receiving : STD_LOGIC := '0';  
    signal pulse_generated : STD_LOGIC := '0';  
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
           
            if receiving = '0' and RX = '0' then
                receiving <= '1'; 
                bit_count <= 0;  
                RX_READY <= '0';  
                pulse_generated <= '0'; 
            elsif receiving = '1' then
              
                if bit_count < 8 then
                    rx_shift_reg <= rx_shift_reg(7 downto 0) & RX; 
                    bit_count <= bit_count + 1;
                    RX_READY <= '0'; 
                else
                   
                    receiving <= '0';
                    RX_DATA <= rx_shift_reg(7 downto 0); 
                    RX_READY <= '1'; 
                    
                    
                    if pulse_generated = '0' then
                        LOAD_PULSE <= '1'; 
                        pulse_generated <= '1'; 
                    end if;
                end if;
            else
                RX_READY <= '0';  
                LOAD_PULSE <= '0'; 
            end if;
        end if;
    end process;
end Behavioral;