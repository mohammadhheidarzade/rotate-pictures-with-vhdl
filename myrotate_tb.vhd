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
BEGIN
    CUT : rotate 
    PORT MAP (
        degree_tb,        
        pic_width_in_tb,  
        pic_height_in_tb, 
        image_in_tb,      
        pic_width_out_tb, 
        pic_height_out_tb,
        image_out_tb     
    );

    PROCESS
        TYPE char_file IS FILE OF CHARACTER;
        FILE bmp_file : char_file OPEN read_mode IS "test1.bmp";
        FILE out_file : char_file OPEN write_mode IS "out1.bmp";
        VARIABLE header : header_type;
        VARIABLE image_in_width  : INTEGER;
        VARIABLE image_in_height : INTEGER;
        VARIABLE image_out_width : INTEGER;
        VARIABLE image_out_height : INTEGER;
        VARIABLE temp_integer : INTEGER;
       
        VARIABLE char : CHARACTER;
        VARIABLE image: image_type;
    BEGIN

        FOR i IN 0 TO 53 LOOP
            read(bmp_file, char);
            header(i) :=
                    std_logic_vector(to_unsigned(character'pos(char), 8));
        END LOOP;
        image_in_width :=to_integer(unsigned(header(18))) +
        to_integer(unsigned(header(19))) * 2**8 +
        to_integer(unsigned(header(20))) * 2**16 +
        to_integer(unsigned(header(21))) * 2**24;
        image_in_height := to_integer(unsigned(header(22))) +
        to_integer(unsigned(header(23))) * 2**8 +
        to_integer(unsigned(header(24))) * 2**16 +
        to_integer(unsigned(header(25))) * 2**24;
        REPORT "image_width: " & INTEGER'image(image_in_width) &
        ", image_height: " & INTEGER'image(image_in_height);
        FOR i IN 0 TO (image_in_height * image_in_width * 3 - 1) LOOP
            read(bmp_file, char);
            image(i) :=
                    std_logic_vector(to_unsigned(character'pos(char), 8));
        END LOOP;
        
        
        degree_tb <= 1;
        image_in_tb <= image;

        wait for 10 ns;
        
        
        image_in_tb <= image;
        pic_width_in_tb <= image_in_width;
        pic_height_in_tb <= image_in_height;
        wait for 10 ns;
        -- pic_width_out_tb  <= pic_width_in_tb;
        -- pic_height_out_tb <= pic_height_in_tb;
        -- image_out_tb      <= image_in_tb;
        -- wait for 10 ns;
        image_out_width := pic_width_out_tb;
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

        file_close(bmp_file);
        file_close(out_file);
        wait;
end process;    
END behavioral ;