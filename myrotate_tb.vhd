USE work.types.all;
use std.textio.all;
use std.env.finish;
USE work.types.all;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rotate_tb IS
END rotate_tb;
ARCHITECTURE behavioral OF rotate_tb IS
    COMPONENT rotate IS
    PORT (
        start           :   IN     STD_LOGIC;
        degree          :   IN     INTEGER RANGE 3 DOWNTO 0;
        
        pic_width_in    :   IN     INTEGER RANGE 2048 DOWNTO 1; 
        pic_height_in   :   IN     INTEGER RANGE 2048 DOWNTO 1;
        image_in        :   IN     image_type;

        pic_width_out   :   OUT    INTEGER RANGE 2048 DOWNTO 1; 
        pic_height_out  :   OUT    INTEGER RANGE 2048 DOWNTO 1;
        image_out       :   OUT    image_type
    );
    END COMPONENT;
    

    SIGNAL degree_tb          :        INTEGER RANGE 3 DOWNTO 0;
    SIGNAL pic_width_in_tb    :        INTEGER RANGE 2048 DOWNTO 1; 
    SIGNAL pic_height_in_tb   :        INTEGER RANGE 2048 DOWNTO 1;
    SIGNAL image_in_tb        :        image_type;
    SIGNAL pic_width_out_tb   :        INTEGER RANGE 2048 DOWNTO 1; 
    SIGNAL pic_height_out_tb  :        INTEGER RANGE 2048 DOWNTO 1;
    SIGNAL image_out_tb       :        image_type;
    SIGNAL start_tb           :     STD_LOGIC := '0';

    SIGNAL key                :     STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL header_sig : header_type;
BEGIN
    CUT : rotate 
    PORT MAP (
        start_tb,
        degree_tb,        
        pic_width_in_tb,  
        pic_height_in_tb, 
        image_in_tb,      
        pic_width_out_tb, 
        pic_height_out_tb,
        image_out_tb     
    );
    key <= "00" ,"01" AFTER 10 ns ,"10" AFTER 20 ns,"11" AFTER 30 ns;
    read_p : PROCESS
        TYPE char_file IS FILE OF CHARACTER;
        FILE bmp_file : char_file OPEN read_mode IS "test3.bmp";
        VARIABLE header : header_type;
        VARIABLE image_in_width  : INTEGER;
        VARIABLE image_in_height : INTEGER;
        VARIABLE char : CHARACTER;
        VARIABLE image: image_type;
    BEGIN
        WAIT UNTIL ( key'EVENT and key="01");
        report "start reading";
        FOR i IN 0 TO 53 LOOP
            read(bmp_file, char);
            header(i) :=
                    std_logic_vector(to_unsigned(character'pos(char), 8));
        END LOOP;
        header_sig <= header;
        image_in_width :=to_integer(unsigned(header(18))) +
        to_integer(unsigned(header(19))) * 2**8 +
        to_integer(unsigned(header(20))) * 2**16 +
        to_integer(unsigned(header(21))) * 2**24;
        image_in_height := to_integer(unsigned(header(22))) +
        to_integer(unsigned(header(23))) * 2**8 +
        to_integer(unsigned(header(24))) * 2**16 +
        to_integer(unsigned(header(25))) * 2**24;
        FOR i IN 0 TO (image_in_height * image_in_width * 3 - 1) LOOP
            read(bmp_file, char);
            image(i) :=
                    std_logic_vector(to_unsigned(character'pos(char), 8));
        END LOOP;
        file_close(bmp_file);
        degree_tb <= 3;
        image_in_tb <= image;
        image_in_tb <= image;
        pic_width_in_tb <= image_in_width;
        pic_height_in_tb <= image_in_height;
        start_tb <= '1';
    END PROCESS read_p;    
    write_P : PROCESS
        TYPE char_file IS FILE OF CHARACTER;
        FILE out_file : char_file OPEN write_mode IS "out1.bmp";
        VARIABLE image_out_width : INTEGER;
        VARIABLE image_out_height : INTEGER;
        VARIABLE char : CHARACTER;
        VARIABLE header : header_type;
        VARIABLE temp_integer : INTEGER;
    begin
        WAIT UNTIL ( key'EVENT and key="10");
        report "start writing";
        header := header_sig;
        image_out_width  := pic_width_out_tb;
        image_out_height := pic_height_out_tb;
        FOR i IN 0 TO 53 LOOP
            IF i >= 18 and i<=21 THEN
                temp_integer := image_out_width MOD 2**8;
                char := character'val(temp_integer);
                image_out_width := image_out_width - temp_integer;
                image_out_width := image_out_width / 2**8;
                write(out_file, char);  
            ELSIF i >= 22 and i<=25 THEN
                temp_integer := image_out_height MOD 2**8;
                char := character'val(temp_integer);
                image_out_height := image_out_height - temp_integer;
                image_out_height := image_out_height / 2**8; 
                write(out_file, char);  
            ELSE
                write(out_file, character'val(to_integer(unsigned(header(i)))));
            END IF;
        END LOOP;
        FOR i IN 0 TO (pic_height_out_tb * pic_width_out_tb * 3 - 1) LOOP
            write(out_file, character'val(to_integer(unsigned(image_out_tb(i)))));
        end loop;
        file_close(out_file);
        report "Simulation done. Check ""out.bmp"" image.";
    END PROCESS write_P;
END behavioral ;