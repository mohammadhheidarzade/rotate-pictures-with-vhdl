LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE types is    -- untested...
    type header_type  is array (0 to 53) of STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE image_type IS ARRAY (0 TO 3000010) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
END types;
PACKAGE BODY types IS
END types;

USE work.types.all;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY rotate IS
  PORT (
    start           :   IN     STD_LOGIC ;
    degree          :   IN     INTEGER RANGE 3 DOWNTO 0;
    pic_width_in    :   IN     INTEGER RANGE 2048 DOWNTO 1; 
    pic_height_in   :   IN     INTEGER RANGE 2048 DOWNTO 1;
    image_in        :   IN     image_type;

    pic_width_out   :   OUT    INTEGER RANGE 2048 DOWNTO 1; 
    pic_height_out  :   OUT    INTEGER RANGE 2048 DOWNTO 1;
    image_out       :   OUT    image_type  
  );
END rotate;

ARCHITECTURE behavioral OF rotate IS
    
BEGIN
    PROCESS
        VARIABLE sinf               :   INTEGER;
        VARIABLE cosf               :   INTEGER;
        VARIABLE x0                 :   INTEGER;
        VARIABLE y0                 :   INTEGER;

        VARIABLE x0_2                 :   INTEGER;
        VARIABLE y0_2                 :   INTEGER;

        VARIABLE xx                 :   INTEGER;
        VARIABLE yy                 :   INTEGER;
        VARIABLE a                  :   INTEGER;
        VARIABLE b                  :   INTEGER;

        VARIABLE a_2                  :   INTEGER;
        VARIABLE b_2                  :   INTEGER;

        VARIABLE x                  :   INTEGER;
        VARIABLE y                  :   INTEGER;
        VARIABLE image_out_TEMP     :   image_type;
        VARIABLE pic_width_out_temp      :   Integer RANGE 2048 DOWNTO 1;
        VARIABLE pic_height_out_temp     :   Integer RANGE 2048 DOWNTO 1;

    BEGIN
        WAIT UNTIL (start'EVENT and start='1');
        
        -- x0 := (pic_width_in - 1) / 2;
        -- y0 := (pic_height_in - 1) / 2;
        x0_2 := (pic_width_in - 1) ;
        y0_2 := (pic_height_in - 1) ;

        report "width: " & integer'image(pic_width_in);
        report "height: " & integer'image(pic_height_in);

        IF degree = 0 THEN
            sinf := 0;
            cosf := 1;
            pic_width_out_temp  :=  pic_width_in  ;
            pic_height_out_temp :=  pic_height_in  ;
        ELSIF degree = 1 THEN
            sinf := 1;
            cosf := 0;
            pic_width_out_temp  :=  pic_height_in  ;
            pic_height_out_temp :=  pic_width_in  ;
        ELSIF degree = 2 THEN
            sinf := 0;
            cosf := -1;
            pic_width_out_temp  :=  pic_width_in  ;
            pic_height_out_temp :=  pic_height_in  ;
        ELSIF degree = 3 THEN
            sinf := -1;
            cosf := 0;
            pic_width_out_temp  :=  pic_height_in  ;
            pic_height_out_temp :=  pic_width_in  ;
        END IF;
        
        
        FOR x IN 0 TO pic_width_in - 1 LOOP
            FOR y IN 0 TO pic_height_in - 1 LOOP
                a :=   ( 2*x - x0_2) ;
                b :=   ( 2*y - y0_2) ;
                xx :=  ((a * cosf) - (b * sinf) + x0_2 ) / 2;
                yy :=  ((a * sinf) + (b * cosf) + y0_2 ) / 2;
                IF xx >= 0 and xx < pic_width_in and yy >= 0 and yy < pic_height_in THEN
                    image_out_TEMP((y * pic_width_in + x) * 3 + 0) := image_in((yy * pic_width_in + xx) * 3 + 0);
                    image_out_TEMP((y * pic_width_in + x) * 3 + 1) := image_in((yy * pic_width_in + xx) * 3 + 1);
                    image_out_TEMP((y * pic_width_in + x) * 3 + 2) := image_in((yy * pic_width_in + xx) * 3 + 2);

                END IF;
            END LOOP; 
        END LOOP;

        image_out       <= image_out_TEMP;
        pic_width_out   <= pic_width_out_temp;
        pic_height_out  <= pic_height_out_temp;
        report "finish myrotate";
    END PROCESS ; -- process
    
    
END behavioral ; -- arch