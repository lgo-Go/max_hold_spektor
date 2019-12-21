library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library std;
use std.textio.all;


entity WriteData is
    generic(
        numOfBits : integer;
        file_name : string
        );
    port(
        clk, dv, sign : in std_logic;
        DataIn : in std_logic_vector ((numOfBits-1) downto 0)
        );
end WriteData;


architecture Behavioral of WriteData is

    constant log_file1 : string := file_name;
    file file_wr: TEXT open write_mode is log_file1;

begin

    write_data : process(clk)
        variable l2 : line;
    begin
        if(rising_edge(clk)) then
            if dv = '1' then
                if sign = '0' then
                    write(l2, CONV_INTEGER(UNSIGNED(DataIn)));
                    writeline(file_wr, l2);
                else
                    write(l2, CONV_INTEGER(SIGNED(DataIn)));
                    writeline(file_wr, l2);
                end if;
            end if;
        end if;
    end process;

end Behavioral;
