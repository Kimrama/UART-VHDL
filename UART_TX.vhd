library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX is
    Port ( CLK : in STD_LOGIC;           
           TX_START : in STD_LOGIC;     
           TX_DATA : in STD_LOGIC_VECTOR (7 downto 0); 
           TX : out STD_LOGIC;          
           TX_BUSY : out STD_LOGIC;        
           LOAD_PULSE : out STD_LOGIC);  
end UART_TX;

architecture Behavioral of UART_TX is
    signal tx_shift_reg : STD_LOGIC_VECTOR (9 downto 0) := (others => '1');
    signal bit_count : integer := 0;  
    signal sending : STD_LOGIC := '0'; 
    signal pulse_generated : STD_LOGIC := '0';
    signal TX_START_edge_detected : STD_LOGIC := '0';  
    signal TX_START_prev : STD_LOGIC := '0'; 
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
           
            if TX_START = '1' and TX_START_prev = '0' then
                TX_START_edge_detected <= '1';
            else
                TX_START_edge_detected <= '0';
            end if;

            TX_START_prev <= TX_START;
				
            if TX_START_edge_detected = '1' and sending = '0' then
                sending <= '1';  
                tx_shift_reg <= '0' & TX_DATA & '1';  
                bit_count <= 0;  
                TX_BUSY <= '1'; 
                pulse_generated <= '0'; 
                LOAD_PULSE <= '0'; 
            elsif sending = '1' then
                if bit_count < 10 then  
                    TX <= tx_shift_reg(9); 
                    tx_shift_reg <= tx_shift_reg(8 downto 0) & '1';  
                    bit_count <= bit_count + 1;
                else
                    sending <= '0'; 
                    TX_BUSY <= '0';  

                   
                    if pulse_generated = '0' then
                        LOAD_PULSE <= '1'; 
                        pulse_generated <= '1';  
                    end if;
                end if;
            else
                LOAD_PULSE <= '0'; 
            end if;
        end if;
    end process;
end Behavioral;