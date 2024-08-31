
CREATE TABLE animal_pen (
    id_animal_pen NUMBER(2) NOT NULL,
    name_pen      VARCHAR2(50) NOT NULL
)
LOGGING;

ALTER TABLE animal_pen
    ADD CONSTRAINT animal_pen_name_pen_ck CHECK ( REGEXP_LIKE ( name_pen,
                                                                '^[a-zA-Z_ ]*$' ) );

COMMENT ON TABLE animal_pen IS
    'records of places where animals live';

ALTER TABLE animal_pen ADD CONSTRAINT animal_pen_pk PRIMARY KEY ( id_animal_pen );

ALTER TABLE animal_pen ADD CONSTRAINT animal_pen_name_pen_uk UNIQUE ( name_pen );

CREATE OR REPLACE PACKAGE animal_pen_package AS
    PROCEDURE add_animal_pen (
        p_name_pen IN animal_pen.name_pen%TYPE
    );

    PROCEDURE delete_animal_pen (
         p_name_pen IN animal_pen.name_pen%TYPE
    );

    PROCEDURE update_animal_pen (
            p_id_animal_pen  IN animal_pen.id_animal_pen%TYPE,
            p_choice  IN VARCHAR2,
            p_updated IN VARCHAR2
    );

    PROCEDURE display_animal_pen;

END animal_pen_package;
/


CREATE OR REPLACE PACKAGE BODY animal_pen_package AS

   ------------------------------ ADD -----------------------------------------------------
    PROCEDURE add_animal_pen (
        p_name_pen IN animal_pen.name_pen%TYPE
    ) IS
    
    BEGIN
        SAVEPOINT add_animal_pen_savepoint; -- SAVEPOINT FOR ROLLBACK IN CASE SMTH IS WRONG
        
        BEGIN
           
            -- CHECK IF NEW NAME IS NOT VALID
            IF p_name_pen IS NULL OR p_name_pen = '' THEN
                RAISE_APPLICATION_ERROR(-20001, 'Name pen must not be empty or null.');
            END IF;
          
            -- INSERT VALUES IF IS VALID
            INSERT INTO animal_pen (name_pen)
            VALUES (p_name_pen);
            
            -- COMMIT TRANSACTION INTO THE DB
            COMMIT;
            
        EXCEPTION
            WHEN dup_val_on_index THEN
                ROLLBACK TO add_animal_pen_savepoint;
                RAISE_APPLICATION_ERROR(-20001, 'A pen with the same name already exists.');
                
            WHEN OTHERS THEN
                ROLLBACK TO add_animal_pen_savepoint;
                RAISE_APPLICATION_ERROR(-20002, 'Error when trying to add animal pen to db ' || SQLERRM);
        END;
    END add_animal_pen;
    
    
    
    ------------------------------ DELETE -----------------------------------------------------
     PROCEDURE delete_animal_pen (
            p_name_pen IN animal_pen.name_pen%TYPE
        ) IS
            v_count NUMBER;
        BEGIN
            SAVEPOINT delete_pen_savepoint; -- SAVEPOINT FOR ROLLBACK IN CASE SMTH IS WRONG
            BEGIN
                        
                -- CHECK IF NAME IS VALID
                IF p_name_pen IS NULL OR p_name_pen = '' THEN
                    RAISE_APPLICATION_ERROR(-20003, 'Name pen must not be empty.');
                END IF;
                
                -- CHECK IF NAME EXISTS IN DB 
                SELECT COUNT(*)
                INTO   v_count
                FROM   animal_pen
                WHERE  name_pen = p_name_pen;
    
                -- IF NOT, RAISE EXCEPTION
                IF v_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20004, 'You are trying to delete an invalid animal ID pen.');
                END IF;
            
            
                -- PROPER DELETE OF ANIMAL ( NAME_PEN IS UNIQUE FIELD )
                DELETE FROM animal_pen
                WHERE name_pen = p_name_pen;
                
                -- CHECK FOR SUCCESSFUL DELETE OPERATION
                IF SQL%NOTFOUND THEN
                    ROLLBACK TO delete_pen_savepoint;
                    RAISE_APPLICATION_ERROR(-20005, 'Pen with name ' || p_name_pen || ' has not been deleted.');
                END IF;
    
                COMMIT; -- COMMIT TRANSACTION
            EXCEPTION
                WHEN OTHERS THEN -- GENERAL ERROR IF SOMETHING APPEAR
                    ROLLBACK TO delete_pen_savepoint;
                    RAISE_APPLICATION_ERROR(-20002, 'Error in deleting pen: ' || SQLERRM);
            END;
        END delete_animal_pen;

    ------------------------------ UPDATE -----------------------------------------------------

       PROCEDURE update_animal_pen (
            p_id_animal_pen  IN animal_pen.id_animal_pen%TYPE,
            p_choice  IN VARCHAR2,
            p_updated IN VARCHAR2
        ) IS

            -- DECLARE CUSTOM EXCEPTIONS
            e_bad_choice EXCEPTION;
            e_no_rows EXCEPTION;
        BEGIN
            SAVEPOINT update_animal_pen_savepoint;
            BEGIN
                -- CHECK IF CHOISE IS ONE OF ATTRIBUTE OF TABLE
                IF p_choice = 'name_pen' THEN
                    
                    -- IF ATTRIBUTE IS VALID, CHECK IF NEW VALUE IS ALSO VALID
                    IF p_updated IS NULL THEN
                          RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                    END IF;
                    
                    -- IF IT IS, THEN UPDATE TABLE AND THEN CHECK IF ACTION TOOK PLACE
                    UPDATE animal_pen SET name_pen = p_updated WHERE id_animal_pen = p_id_animal_pen;
                    
                    IF SQL%NOTFOUND THEN
                        RAISE e_no_rows;
                    END IF;
                    
                ELSE
                    RAISE e_bad_choice;
                END IF;
                
                COMMIT;
            
            EXCEPTION
                WHEN e_bad_choice THEN
                    RAISE_APPLICATION_ERROR(-20201, 'No attribute like ' || p_choice || ' found !');
                    
                WHEN dup_val_on_index THEN 
                    RAISE_APPLICATION_ERROR(-20001, 'A pen with the same name already exists.');
                    
                WHEN e_no_rows THEN  
                    RAISE_APPLICATION_ERROR(-20202, 'Pen with ID' || TO_CHAR(p_id_animal_pen) || ' does not exist.');
                    
                WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20002, 'Error in updating pen: ' || TO_CHAR(p_id_animal_pen) || ': ' || SQLERRM);
            END;
        END update_animal_pen;
        
    

        PROCEDURE display_animal_pen IS
        BEGIN
            FOR rec IN (SELECT * FROM animal_pen) LOOP
                DBMS_OUTPUT.PUT_LINE('ID: ' || rec.id_animal_pen || ', Name: ' || rec.name_pen);
            END LOOP;
        END display_animal_pen;

END animal_pen_package;
/

CREATE TABLE animal_type (
    id_animal_type NUMBER(2) NOT NULL,
    type_animal    VARCHAR2(50) NOT NULL
)
LOGGING;

ALTER TABLE animal_type
    ADD CHECK ( type_animal IN ( 'Arachnids', 'Bird', 'Canine', 'Feline', 'Fish',
                                 'Insect', 'Reptiles', 'Rodent' ) );

COMMENT ON TABLE animal_type IS
    'generic type of animals wich help to identify characteristics of an animal';

ALTER TABLE animal_type ADD CONSTRAINT animal_type_pk PRIMARY KEY ( id_animal_type );

ALTER TABLE animal_type ADD CONSTRAINT animaltype_typeanimal_uk UNIQUE ( type_animal );

CREATE OR REPLACE PACKAGE animal_type_package AS
    PROCEDURE add_animal_type (
        p_type_animal IN animal_type.type_animal%TYPE
    );

    PROCEDURE delete_animal_type ( 
            p_type_animal IN animal_type.type_animal%TYPE
    );

    PROCEDURE update_animal_type (
         p_id_animal_type  IN animal_type.id_animal_type%TYPE,
            p_choice  IN VARCHAR2,
            p_updated IN VARCHAR2
    );

    PROCEDURE display_animal_type;

END animal_type_package;
/

CREATE OR REPLACE PACKAGE BODY animal_type_package AS

      ------------------------------ ADD -----------------------------------------------------
    PROCEDURE add_animal_type (
        p_type_animal IN animal_type.type_animal%TYPE
    ) IS
    BEGIN
        SAVEPOINT add_animal_type_savepoint;
        
        BEGIN
         -- CHECK IF NEW NAME IS NOT VALID
            IF p_type_animal IS NULL OR p_type_animal = '' THEN
                RAISE_APPLICATION_ERROR(-20001, 'Name type must not be empty.');
            END IF;
            
              -- INSERT VALUES IF IS VALID
            INSERT INTO animal_type (type_animal)
            VALUES (p_type_animal);
            
             -- COMMIT TRANSACTION INTO THE DB
            COMMIT;
            
        EXCEPTION
            WHEN dup_val_on_index THEN
                ROLLBACK TO add_animal_type_savepoint;
                RAISE_APPLICATION_ERROR(-20001, 'An animal type with the same name already exists.');
                
            WHEN OTHERS THEN
                ROLLBACK TO add_animal_type_savepoint;
                RAISE_APPLICATION_ERROR(-20002, 'Error when trying to add animal type to db ' || SQLERRM);
        END;
    END add_animal_type;

    ------------------------------ DELETE -----------------------------------------------------    
     PROCEDURE delete_animal_type (
            p_type_animal IN animal_type.type_animal%TYPE
        ) IS
             v_count NUMBER;
        BEGIN
            SAVEPOINT delete_type_savepoint;
            BEGIN
                -- CHECK IF NAME IS VALID
                IF p_type_animal IS NULL OR p_type_animal = '' THEN
                    RAISE_APPLICATION_ERROR(-20003, 'Name type must not be empty.');
                END IF;
                
                -- CHECK IF NAME EXISTS IN DB
                SELECT COUNT(*)
                INTO   v_count
                FROM   animal_type
                WHERE  type_animal = p_type_animal;
    
                 -- IF NOT, RAISE EXCEPTION
                IF v_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20004, 'You are trying to delete an invalid animal ID type.');
                END IF;
            
                -- PROPER DELETE OF ANIMAL ( type_animal IS UNIQUE FIELD )
                DELETE FROM animal_type
                WHERE type_animal = p_type_animal;
                
                 -- CHECK FOR SUCCESSFUL DELETE OPERATION
                IF SQL%NOTFOUND THEN
                    ROLLBACK TO delete_type_savepoint;
                    RAISE_APPLICATION_ERROR(-20005, 'Animal with type ' || p_type_animal || ' not found.');
                END IF;
    
                COMMIT;  -- COMMIT TRANSACTION
            EXCEPTION
                WHEN OTHERS THEN -- GENERAL ERROR IF SOMETHING APPEAR
                    ROLLBACK TO delete_type_savepoint;
                    RAISE_APPLICATION_ERROR(-20002, 'Error in deleting typeanimal: ' || SQLERRM);
                    
            END;
        END delete_animal_type;

    ------------------------------ UPDATE -----------------------------------------------------
       PROCEDURE update_animal_type (
            p_id_animal_type  IN animal_type.id_animal_type%TYPE,
            p_choice  IN VARCHAR2,
            p_updated IN VARCHAR2
        ) IS
            e_bad_choice EXCEPTION;
            e_no_rows EXCEPTION;
        BEGIN
            SAVEPOINT update_animal_type_savepoint;
            BEGIN
                -- CHECK IF CHOISE IS ONE OF ATTRIBUTE OF TABLE
                IF p_choice = 'type_animal' THEN
                
                    -- IF ATTRIBUTE IS VALID, CHECK IF NEW VALUE IS ALSO VALID
                    IF p_updated IS NULL THEN
                          RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                    END IF;
                    
                    -- IF IT IS, THEN UPDATE TABLE AND THEN CHECK IF ACTION TOOK PLACE
                    UPDATE animal_type SET type_animal = p_updated WHERE id_animal_type = p_id_animal_type;
                    
                    IF SQL%NOTFOUND THEN
                        RAISE e_no_rows;
                    END IF;
                    
                ELSE
                    RAISE e_bad_choice;
                END IF;
                
                COMMIT;
            
            EXCEPTION
                WHEN e_bad_choice THEN
                    RAISE_APPLICATION_ERROR(-20201, 'No attribute like ' || p_choice || ' found !');
                    
                WHEN DUP_VAL_ON_INDEX THEN 
                    RAISE_APPLICATION_ERROR(-20001, 'A type with the same name already exists.');
                    
                WHEN e_no_rows THEN  
                    RAISE_APPLICATION_ERROR(-20202, 'Type with ID' || TO_CHAR(p_id_animal_type) || ' does not exist.');
                    
                WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20002, 'Error in updating pen: ' || TO_CHAR(p_id_animal_type) || ': ' || SQLERRM);
            END;
        END update_animal_type;
        
    

        PROCEDURE display_animal_type IS
        BEGIN
            FOR rec IN (SELECT * FROM animal_type) LOOP
                DBMS_OUTPUT.PUT_LINE('ID: ' || rec.id_animal_type || ', Type: ' || rec.type_animal);
            END LOOP;
        END display_animal_type;

END animal_type_package;
/

CREATE TABLE animals (
    id_animals     NUMBER(3) NOT NULL,
    id_animal_type NUMBER(2) NOT NULL,
    id_animal_pen  NUMBER(2) NOT NULL
)
LOGGING;

COMMENT ON TABLE animals IS
    'main tabel where it is keeped id of animal and details about animal pen where it lives';

ALTER TABLE animals ADD CONSTRAINT animals_pk PRIMARY KEY ( id_animals );

CREATE TABLE animal_info (
    id_animals NUMBER(3) NOT NULL,
    name       VARCHAR2(50) NOT NULL,
    birth_date DATE NOT NULL,
    gender     VARCHAR2(20) NOT NULL
)
LOGGING;

ALTER TABLE animal_info
    ADD CONSTRAINT animal_info_name_ck CHECK ( REGEXP_LIKE ( name,
                                                             '^[a-zA-Z_ ]*$' ) );

ALTER TABLE animal_info
    ADD CHECK ( gender IN ( 'Female', 'Male' ) );

COMMENT ON TABLE animal_info IS
    'general info about animal and its life';

ALTER TABLE animal_info ADD CONSTRAINT animals_id_animals_uk PRIMARY KEY ( id_animals );

CREATE TABLE diet (
    id_diet    NUMBER(5) NOT NULL,
    id_food    NUMBER(2) NOT NULL,
    id_animals NUMBER(3) NOT NULL,
    diet_type  VARCHAR2(20) NOT NULL,
    quantity   NUMBER(5) NOT NULL
)
LOGGING;

ALTER TABLE diet
    ADD CONSTRAINT check_diet_type CHECK ( diet_type IN ( 'Carnivor', 'Erbivor', 'Omnivor' ) );

ALTER TABLE diet
    ADD CONSTRAINT diet_quantity_ck CHECK ( REGEXP_LIKE ( quantity,
                                                          '[+-]?([0-9]*[.])?[0-9]+' ) );

COMMENT ON TABLE diet IS
    'diet contains type of food and for what animal is it suitable for';

ALTER TABLE diet
    ADD CONSTRAINT diet_pk PRIMARY KEY ( id_diet,
                                         id_food,
                                         id_animals );

CREATE TABLE medical_info (
    id_medical_info   NUMBER(2) NOT NULL,
    id_animals        NUMBER(3) NOT NULL,
    data_registration DATE NOT NULL,
    birth_date        DATE NOT NULL,
    children          VARCHAR2(5) NOT NULL,
    surgery           VARCHAR2(50) NOT NULL,
    medication        VARCHAR2(50) NOT NULL
)
LOGGING;

ALTER TABLE medical_info
    ADD CHECK ( children IN ( 'No', 'Yes' ) );

COMMENT ON TABLE medical_info IS
    'contains records about medical life of animals to let employees know how every animal is feeling';

ALTER TABLE medical_info ADD CONSTRAINT medical_info_pk PRIMARY KEY ( id_medical_info );

CREATE OR REPLACE PACKAGE animals_package AS
    PROCEDURE add_animal (
         p_id_type     IN animals.id_animal_type%TYPE,
        p_id_pen      IN animals.id_animal_pen%TYPE,
        p_name        IN animal_info.name%TYPE,
        p_birth_date  IN animal_info.birth_date%TYPE,
        p_gender      IN animal_info.gender%TYPE
    );

    PROCEDURE delete_animal (
        p_id_animal IN animals.id_animals%TYPE
    );

    PROCEDURE update_animal (
        p_id_animal IN animals.id_animals%TYPE,
        p_choice    IN VARCHAR2,
        p_updated   IN VARCHAR2
    );

    PROCEDURE display_animal;
    PROCEDURE display_animal_info;
END animals_package;
/

CREATE OR REPLACE PACKAGE BODY animals_package AS

    PROCEDURE add_animal (
        p_id_type     IN animals.id_animal_type%TYPE,
        p_id_pen      IN animals.id_animal_pen%TYPE,
        p_name        IN animal_info.name%TYPE,
        p_birth_date  IN animal_info.birth_date%TYPE,
        p_gender      IN animal_info.gender%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SAVEPOINT savepoint_add_animal ;
        BEGIN
            IF p_id_type IS NULL 
            OR p_id_pen IS NULL 
            OR p_name IS NULL 
            OR p_birth_date IS NULL 
            OR p_gender IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'All fields must be provided.');
            END IF;
    
            SELECT COUNT(*)
            INTO   v_count
            FROM   animal_type
            WHERE  id_animal_type = p_id_type;
    
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20011, 'Invalid animal type ID.');
            END IF;
    
            SELECT COUNT(*)
            INTO   v_count
            FROM   animal_pen
            WHERE  id_animal_pen = p_id_pen;
    
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20012, 'Invalid animal pen ID.');
            END IF;
    
            INSERT INTO animals (
                ID_Animal_Type,
                ID_Animal_Pen
            ) VALUES (
                p_id_type,
                p_id_pen
            );
    
            INSERT INTO animal_info (
                Name,
                Birth_Date,
                Gender
            ) VALUES (
                p_name,
                p_birth_date,
                p_gender
            );
    
            COMMIT;
        EXCEPTION
    
            WHEN dup_val_on_index THEN
                ROLLBACK TO savepoint_add_animal;
                RAISE_APPLICATION_ERROR(-20001, 'An animal with the same id already exists.');
                
            WHEN OTHERS THEN
                ROLLBACK TO savepoint_add_animal;
                RAISE_APPLICATION_ERROR(-20002, 'Error when trying to add animal  to db ' || SQLERRM);

        END;
        
    
    END add_animal;
    
    
    
    PROCEDURE delete_animal (
        p_id_animal IN animals.id_animals%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SAVEPOINT delete_animal_savepoint;

        BEGIN
          -- CHECK IF ID IS VALID
            IF p_id_animal IS NULL OR p_id_animal = '' THEN
                RAISE_APPLICATION_ERROR(-20003, 'ID animal must not be empty.');
            END IF;
                
            --CHECK FOR ANIMAL ID IN CENTRAL TABEL -> ANIMALS
            SELECT COUNT(*)
            INTO   v_count
            FROM   animals
            WHERE  id_animals = p_id_animal;

            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20004, 'You are trying to delete an invalid animal ID.');
            END IF;

            -- CHECK IF EXISTS IN DIET
            SELECT COUNT(*)
            INTO   v_count
            FROM   diet
            WHERE  id_animals = p_id_animal; 

            IF v_count > 0 THEN
                -- DELETE FROM DIET AND CHECK FOR SUCCESS DELETE
                DELETE FROM diet
                WHERE  id_animals = p_id_animal;
                
                IF SQL%NOTFOUND THEN
                    RAISE_APPLICATION_ERROR(-20017, 'Error deleting from diet.');
                END IF;
            END IF;

            -- CHECK IF EXISTS IN MEDICAL INFO
            SELECT COUNT(*)
            INTO   v_count
            FROM   medical_info
            WHERE  id_animals = p_id_animal;

            IF v_count > 0 THEN
                -- DELETE FROM MEDICAL INFO AND CHECK FOR SUCCESS DELETE
                DELETE FROM medical_info
                WHERE  id_animals = p_id_animal;
                
                IF SQL%NOTFOUND THEN
                    RAISE_APPLICATION_ERROR(-20018, 'Error deleting from medical_info.');
                END IF;
            END IF;

            -- CHECK IF EXISTS IN ANIMAL INFO
            SELECT COUNT(*)
            INTO   v_count
            FROM   animal_info
            WHERE  id_animals = p_id_animal;

            IF v_count > 0 THEN
                -- DELETE FROM ANIMAL INFO AND CHECK FOR SUCCESS DELETE
                DELETE FROM animal_info
                WHERE  id_animals = p_id_animal;
                
                IF SQL%NOTFOUND THEN
                    RAISE_APPLICATION_ERROR(-20019, 'Error deleting from animal_info.');
                END IF;
            END IF;

            -- PROPER DELETE OF ANIMAL 
            DELETE FROM animals
            WHERE  id_animals = p_id_animal;
            
            -- CHECK FOR SUCCESSFUL DELETE OPERATION
            IF SQL%NOTFOUND THEN
                ROLLBACK TO delete_animal_savepoint;
                RAISE_APPLICATION_ERROR(-20005, 'aNIMAL with ID ' || p_id_animal || ' has not been deleted.');
            END IF;
            
            COMMIT; -- COMMIT TRANSACTION
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO delete_animal_savepoint;
                RAISE_APPLICATION_ERROR(-20020, 'Error in deleting animal: ' || SQLERRM);
        END;
    END delete_animal;
    
    
    
    PROCEDURE update_animal (
        p_id_animal IN animals.id_animals%TYPE,
        p_choice    IN VARCHAR2,
        p_updated   IN VARCHAR2
    ) IS
        e_no_rows        EXCEPTION;
        e_bad_choice     EXCEPTION;
        v_count          NUMBER;
    BEGIN
        SAVEPOINT update_animal_savepoint;

        BEGIN 
            -- FIRST CHECK FOR FK SO IT MUST EXISTS
            IF (p_choice = 'id_animal_type') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                SELECT COUNT(*)
                INTO v_count
                FROM animal_type
                WHERE id_animal_type = TO_NUMBER(p_updated);
                
                IF v_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20202, 'New id animal type does not exists');
                END IF;
       
                UPDATE animals
                SET id_animal_type = TO_NUMBER(p_updated)
                WHERE id_animals = p_id_animal;
                
                 IF SQL%NOTFOUND THEN
                        RAISE e_no_rows;
                    END IF;
            -- FIRST CHECK FOR FK SO IT MUST EXISTS
            ELSIF (p_choice = 'id_animal_pen') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                SELECT COUNT(*)
                INTO v_count
                FROM animal_pen
                WHERE id_animal_pen = TO_NUMBER(p_updated);
                
                IF v_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20202, 'New id animal pen does not exists');
                END IF;
                
             
                UPDATE animals
                SET id_animal_pen = TO_NUMBER(p_updated)
                WHERE id_animals = p_id_animal;
                
            -- REST OF FIELDS FROM ANIMAL_INFO  
            ELSIF (p_choice = 'name') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE animal_info
                SET name = p_updated
                WHERE id_animals = p_id_animal;
                
                 IF SQL%NOTFOUND THEN
                    RAISE e_no_rows;
                END IF;
            
            ELSIF (p_choice = 'birth_date') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE animal_info
                SET birth_date = TO_DATE(p_updated, 'yyyy-mm-dd')
                WHERE id_animals = p_id_animal;
                
                 IF SQL%NOTFOUND THEN
                    RAISE e_no_rows;
                END IF;
                
            ELSIF (p_choice = 'gender') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE animal_info
                SET gender = p_updated
                WHERE id_animals = p_id_animal;
                
                 IF SQL%NOTFOUND THEN
                    RAISE e_no_rows;
                END IF;
            ELSE
                RAISE e_bad_choice;
            END IF;

            COMMIT;
        EXCEPTION
            WHEN e_bad_choice THEN
                RAISE_APPLICATION_ERROR(-20201,  'No attribute like '||p_choice||' found !');
            WHEN e_no_rows THEN
                RAISE_APPLICATION_ERROR(-20201, 'Animal with id ' || p_id_animal || ' does not exists.');
            WHEN OTHERS THEN
                ROLLBACK TO update_animal_savepoint;
                RAISE_APPLICATION_ERROR(-20002, 'Error in updating ' || p_id_animal || ': ' || SQLERRM);
        
        END; 

    
    END update_animal;

    
    
    
    
    PROCEDURE display_animal IS
    BEGIN
        FOR rec IN (SELECT a.id_animals,
                           at.type_animal,
                           ap.name_pen,
                           ai.name,
                           ai.birth_date,
                           ai.gender
                    FROM animals a
                    JOIN animal_type at ON a.id_animal_type = at.id_animal_type
                    JOIN animal_pen ap ON a.id_animal_pen = ap.id_animal_pen
                    JOIN animal_info ai ON a.id_animals = ai.id_animals)
        LOOP
            DBMS_OUTPUT.PUT_LINE('Animal ID: ' || rec.id_animals);
            DBMS_OUTPUT.PUT_LINE('Animal Type: ' || rec.type_animal);
            DBMS_OUTPUT.PUT_LINE('Animal Pen: ' || rec.name_pen);
            DBMS_OUTPUT.PUT_LINE('Name: ' || rec.name);
            DBMS_OUTPUT.PUT_LINE('Birth Date: ' || TO_CHAR(rec.birth_date, 'yyyy-mm-dd'));
            DBMS_OUTPUT.PUT_LINE('Gender: ' || rec.gender);
            DBMS_OUTPUT.PUT_LINE('-------------------------');
        END LOOP;
    END display_animal;

    PROCEDURE display_animal_info IS
    BEGIN
        FOR rec IN (SELECT id_animals,
                           name,
                           birth_date,
                           gender
                    FROM animal_info)
        LOOP
            DBMS_OUTPUT.PUT_LINE('Animal ID: ' || rec.id_animals);
            DBMS_OUTPUT.PUT_LINE('Name: ' || rec.name);
            DBMS_OUTPUT.PUT_LINE('Birth Date: ' || TO_CHAR(rec.birth_date, 'yyyy-mm-dd'));
            DBMS_OUTPUT.PUT_LINE('Gender: ' || rec.gender);
            DBMS_OUTPUT.PUT_LINE('-------------------------');
        END LOOP;
    END display_animal_info;
END animals_package;
/

CREATE TABLE food (
    id_food          NUMBER(5) NOT NULL,
    food_type        VARCHAR2(50) NOT NULL,
    quantity_wk_food NUMBER(5) NOT NULL
)
LOGGING;

ALTER TABLE food
    ADD CONSTRAINT food_food_type_ck CHECK ( REGEXP_LIKE ( food_type,
                                                           '^[a-zA-Z_ ]*$' ) );

COMMENT ON TABLE food IS
    'food actually contains types of food available for animals';

ALTER TABLE food ADD CONSTRAINT food_pk PRIMARY KEY ( id_food );

CREATE OR REPLACE PACKAGE diet_package AS

    PROCEDURE add_diet (
        p_id_food    IN diet.id_food%TYPE,
        p_id_animals IN diet.id_animals%TYPE,
        p_diet_type  IN diet.diet_type%TYPE,
        p_quantity   IN diet.quantity%TYPE
    );

    PROCEDURE delete_diet (
        p_id_diet IN diet.id_diet%TYPE
    );

    PROCEDURE update_diet (
        p_id_diet   IN diet.id_diet%TYPE,
        p_choice    IN VARCHAR2,
        p_updated   IN VARCHAR2
    );

    PROCEDURE display_diet;
END diet_package;
/

CREATE OR REPLACE PACKAGE BODY diet_package AS

    PROCEDURE add_diet (
        p_id_food    IN diet.id_food%TYPE,
        p_id_animals IN diet.id_animals%TYPE,
        p_diet_type  IN diet.diet_type%TYPE,
        p_quantity   IN diet.quantity%TYPE
    ) IS
         v_count NUMBER;
    BEGIN
        SAVEPOINT savepoint_add_diet ;
        BEGIN
            -- CHECK FOR  NULL
            IF p_id_food IS NULL 
            OR p_id_animals IS NULL 
            OR p_diet_type IS NULL 
            OR p_quantity IS NULL 
            THEN
                RAISE_APPLICATION_ERROR(-20001, 'All fields must be provided.');
            END IF;
        
            -- CHECK IF ALREADY EXISTS ANIMAL FK IN ITS OWN TABLE
            SELECT COUNT(*)
            INTO   v_count
            FROM   animals
            WHERE  id_animals = p_id_animals;
    
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20011, 'Invalid animal type ID.');
            END IF;
    
    
            -- CHECK IF ALREADY EXISTS FOOD FK IN ITS OWN TABLE
            SELECT COUNT(*)
            INTO   v_count
            FROM   food
            WHERE  id_food = p_id_food;
    
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20011, 'Invalid food  ID.');
            END IF;
            
            
            INSERT INTO diet (
            id_food,
            id_animals,
            diet_type,
            quantity
            ) VALUES (
                p_id_food,
                p_id_animals,
                p_diet_type,
                p_quantity
            );
            
            COMMIT;
        EXCEPTION
            WHEN dup_val_on_index THEN
                ROLLBACK TO savepoint_add_diet;
                RAISE_APPLICATION_ERROR(-20001, 'An diet with the same id already exists.');
                
            WHEN OTHERS THEN
                ROLLBACK TO savepoint_add_diet;
                RAISE_APPLICATION_ERROR(-20002, 'Error when trying to add diet  to db ' || SQLERRM);
        END;
    END add_diet;




    PROCEDURE delete_diet (
        p_id_diet IN diet.id_diet%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SAVEPOINT delete_diet_savepoint;
        BEGIN
             -- CHECK IF ID IS VALID
            IF p_id_diet IS NULL OR p_id_diet = '' THEN
                RAISE_APPLICATION_ERROR(-20003, 'ID diet must not be empty.');
            END IF;
            
            --CHECK FOR DIET ID IN CENTRAL TABEL -> DIET
            SELECT COUNT(*)
            INTO   v_count
            FROM   diet
            WHERE  id_diet = p_id_diet;

            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20004, 'You are trying to delete an invalid diet ID.');
            END IF;
            
            -- PROPER DELETE OF ANIMAL 
            DELETE FROM diet
            WHERE   id_diet = p_id_diet;

            -- CHECK FOR SUCCESSFUL DELETE OPERATION
            IF SQL%NOTFOUND THEN
                ROLLBACK TO delete_diet_savepoint;
                RAISE_APPLICATION_ERROR(-20005, 'Diet with ID ' || p_id_diet || ' has not been deleted.');
            END IF;
            
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO delete_diet_savepoint;
                RAISE_APPLICATION_ERROR(-20020, 'Error in deleting diet: ' || SQLERRM);
        END;
    END delete_diet;




    PROCEDURE update_diet (
        p_id_diet  IN diet.id_diet%TYPE,
        p_choice   IN VARCHAR2,
        p_updated  IN VARCHAR2
    ) IS
        e_no_rows        EXCEPTION;
        e_bad_choice     EXCEPTION;
        v_count          NUMBER;
    BEGIN
        SAVEPOINT update_diet_savepoint;
        BEGIN 
            -- FIRST CHECK FOR FK SO IT MUST EXISTS
            IF (p_choice = 'id_animals') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                SELECT COUNT(*)
                INTO v_count
                FROM animals
                WHERE id_animals = TO_NUMBER(p_updated);
                
                IF v_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20202, 'New id animal type does not exists');
                END IF;
       
                UPDATE diet
                SET id_animals = TO_NUMBER(p_updated)
                WHERE id_diet = p_id_diet;
                
                IF SQL%NOTFOUND THEN
                        RAISE e_no_rows;
                END IF;
                
            -- FIRST CHECK FOR FK SO IT MUST EXISTS
            ELSIF (p_choice = 'id_food') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                SELECT COUNT(*)
                INTO v_count
                FROM food
                WHERE id_food = TO_NUMBER(p_updated);
                
                IF v_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20202, 'New id food  does not exists');
                END IF;
                
             
                UPDATE diet
                SET id_food = TO_NUMBER(p_updated)
                WHERE id_diet = p_id_diet;
                 
                IF SQL%NOTFOUND THEN
                        RAISE e_no_rows;
                END IF;
                
            -- REST OF FIELDS FROM DIET  
            ELSIF p_choice = 'diet_type' THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE diet 
                SET diet_type = p_updated 
                WHERE id_diet = p_id_diet;
                
                IF SQL%NOTFOUND THEN
                    RAISE e_no_rows;
                END IF;
                
            ELSIF p_choice = 'quantity' THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE diet
                SET quantity = TO_NUMBER(p_updated) 
                WHERE id_diet = p_id_diet;
                
                IF SQL%NOTFOUND THEN
                    RAISE e_no_rows;
                END IF;
            ELSE
                RAISE e_bad_choice;
            END IF;
            
            COMMIT;
        EXCEPTION
            WHEN e_bad_choice THEN
                RAISE_APPLICATION_ERROR(-20201,  'No attribute like '||p_choice||' found !');
            WHEN e_no_rows THEN
                RAISE_APPLICATION_ERROR(-20201, 'dIET with id ' || p_id_diet || ' does not exists.');
            WHEN OTHERS THEN
                ROLLBACK TO update_diet_savepoint;
                RAISE_APPLICATION_ERROR(-20002, 'Error in updating ' || p_id_diet || ': ' || SQLERRM);
         END;
    END update_diet;

    PROCEDURE display_diet IS
    BEGIN
        FOR rec IN (SELECT d.id_diet,
                           f.food_type,
                           a.name,
                           d.diet_type,
                           d.quantity
                    FROM diet d
                    JOIN food f ON d.id_food = f.id_food
                    JOIN animal_info a ON d.id_animals = a.id_animals)
        LOOP
            DBMS_OUTPUT.PUT_LINE('Diet ID: ' || rec.id_diet);
            DBMS_OUTPUT.PUT_LINE('Food Type: ' || rec.food_type);
            DBMS_OUTPUT.PUT_LINE('Animal Name: ' || rec.name);
            DBMS_OUTPUT.PUT_LINE('Diet Type: ' || rec.diet_type);
            DBMS_OUTPUT.PUT_LINE('Quantity: ' || rec.quantity);
            DBMS_OUTPUT.PUT_LINE('-------------------------');
        END LOOP;
    END display_diet;

END diet_package;
/

CREATE OR REPLACE PACKAGE food_package AS
    PROCEDURE add_food (
        p_food_type    IN food.food_type%TYPE,
        p_quantity_wk_food   IN food.quantity_wk_food%TYPE
    );

    PROCEDURE delete_food (
        p_id_food IN food.id_food%TYPE
    );

    PROCEDURE update_food (
        p_id_food IN food.id_food%TYPE,
        p_choice    IN VARCHAR2,
        p_updated   IN VARCHAR2
    );

    PROCEDURE display_food;
END food_package;
/

CREATE OR REPLACE PACKAGE BODY food_package AS

    PROCEDURE add_food (
        p_food_type           IN food.food_type%TYPE,
        p_quantity_wk_food    IN food.quantity_wk_food%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SAVEPOINT savepoint_add_food;
        
        BEGIN
            IF p_food_type IS NULL 
            OR p_quantity_wk_food IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'All fields must be provided.');
            END IF;
    
            SELECT COUNT(*)
            INTO   v_count
            FROM   food
            WHERE  food_type = p_food_type;
    
            IF v_count > 0 THEN
                RAISE_APPLICATION_ERROR(-21002, 'Food with the same id already exists.');
            END IF;

            INSERT INTO food (
                food_type,
                quantity_wk_food
            ) VALUES (
                p_food_type,
                p_quantity_wk_food
            );
    
            COMMIT;
        
        EXCEPTION
            WHEN dup_val_on_index THEN
                ROLLBACK TO savepoint_add_food;
                RAISE_APPLICATION_ERROR(-20001, 'Food with the same id already exists.');
                
            WHEN OTHERS THEN
                ROLLBACK TO savepoint_add_food;
                RAISE_APPLICATION_ERROR(-20002, 'Error when trying to add food to db ' || SQLERRM);
        END;
    END add_food;
    
    
    PROCEDURE delete_food (
        p_id_food IN food.id_food%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SAVEPOINT savepoint_delete_food;

        BEGIN
            -- CHECK IF ID IS VALID
            IF p_id_food IS NULL OR p_id_food = '' THEN
                RAISE_APPLICATION_ERROR(-20003, 'ID food must not be empty.');
            END IF;
                
            --CHECK FOR FOOD ID IN CENTRAL TABEL -> MUST EXISTS
            SELECT COUNT(*)
            INTO v_count
            FROM food
            WHERE id_food = p_id_food;
            
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20004, 'You are trying to delete an invalid food ID.');
            END IF;
            
            -- CHECK IF EXISTS IN DIET
            SELECT COUNT(*)
            INTO v_count
            FROM diet
            WHERE id_food = p_id_food;

            IF v_count > 0 THEN
                -- DELETE FROM DIET AND CHECK FOR SUCCESS DELETE
                DELETE FROM diet
                WHERE  id_food = p_id_food;
                
                IF SQL%NOTFOUND THEN
                    RAISE_APPLICATION_ERROR(-20017, 'Error deleting from diet.');
                END IF;
            END IF;
            
            -- PROPER DELETE OF FOOD 
            DELETE FROM food WHERE id_food = p_id_food;
            
            -- CHECK FOR SUCCESSFUL DELETE OPERATION
            IF SQL%NOTFOUND THEN
                ROLLBACK TO delete_animal_savepoint;
                RAISE_APPLICATION_ERROR(-20005, 'FOOD with ID ' || p_id_food || ' has not been deleted.');
            END IF;
            
            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO savepoint_delete_food;
                RAISE_APPLICATION_ERROR(-21009, 'Error when trying to delete food from db ' || SQLERRM);
        END;

    END delete_food;


    PROCEDURE update_food (
        p_id_food  IN food.id_food%TYPE,
        p_choice    IN VARCHAR2,
        p_updated   IN VARCHAR2
    ) IS
        e_no_rows        EXCEPTION;
        e_bad_choice     EXCEPTION;
        v_count NUMBER;
    BEGIN
        SAVEPOINT savepoint_update_food;

        BEGIN
            IF p_choice = 'food_type' THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE food 
                SET food_type = p_updated 
                WHERE id_food = p_id_food;
                
                IF SQL%NOTFOUND THEN
                    RAISE e_no_rows;
                END IF;
                
            ELSIF p_choice = 'quantity_wk_food' THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE food
                SET quantity_wk_food = TO_NUMBER(p_updated) 
                WHERE id_food = p_id_food;
                
                IF SQL%NOTFOUND THEN
                    RAISE e_no_rows;
                END IF;
                
            ELSE
                RAISE e_bad_choice;
            END IF;

            COMMIT;

        EXCEPTION
            WHEN e_bad_choice THEN
                RAISE_APPLICATION_ERROR(-20201,  'No attribute like '||p_choice||' found !');
            WHEN e_no_rows THEN
                RAISE_APPLICATION_ERROR(-20201, 'Food with id ' || p_id_food || ' does not exists.');
                
            WHEN OTHERS THEN
                ROLLBACK TO savepoint_update_food;
                RAISE_APPLICATION_ERROR(-21012, 'Error when trying to update food in db ' || SQLERRM);
        END;

    END update_food;
    
    PROCEDURE display_food AS
    BEGIN
        FOR rec IN (SELECT *
                    FROM food f
                    ORDER BY f.id_food)
        LOOP
            DBMS_OUTPUT.PUT_LINE('Food ID: ' || rec.id_food);
            DBMS_OUTPUT.PUT_LINE('Food Type: ' || rec.food_type);
            DBMS_OUTPUT.PUT_LINE('Quantity per Week: ' || rec.quantity_wk_food);
            DBMS_OUTPUT.PUT_LINE('-------------------------');
        END LOOP;
    END display_food;
    
END food_package;
/

CREATE OR REPLACE PACKAGE medical_info_package AS
    PROCEDURE add_medical_info (
        p_id_animals        IN medical_info.id_animals%TYPE,
        p_data_registration IN medical_info.data_registration%TYPE,
        p_birth_date        IN medical_info.birth_date%TYPE,
        p_children          IN medical_info.children%TYPE,
        p_surgery           IN medical_info.surgery%TYPE,
        p_medication        IN medical_info.medication%TYPE
    );

    PROCEDURE delete_medical_info (
        p_id_medical IN medical_info.id_medical_info%TYPE
    );

    PROCEDURE update_medical_info (
        p_id_medical IN medical_info.id_medical_info%TYPE,
        p_choice     IN VARCHAR2,
        p_updated    IN VARCHAR2
    );

    PROCEDURE display_medical_info;

END medical_info_package;
/

CREATE OR REPLACE PACKAGE BODY medical_info_package AS

    PROCEDURE add_medical_info (
        p_id_animals        IN medical_info.id_animals%TYPE,
        p_data_registration IN medical_info.data_registration%TYPE,
        p_birth_date        IN medical_info.birth_date%TYPE,
        p_children          IN medical_info.children%TYPE,
        p_surgery           IN medical_info.surgery%TYPE,
        p_medication        IN medical_info.medication%TYPE
    ) IS
        v_count          NUMBER;
    BEGIN
        SAVEPOINT savepoint_add_medical_info ;
        BEGIN
            --CHECK IF NOT NULL
            IF p_id_animals IS NULL 
            OR p_data_registration IS NULL 
            OR p_birth_date IS NULL 
            OR p_children IS NULL 
            OR p_surgery IS NULL 
            OR p_medication IS NULL THEN
                RAISE_APPLICATION_ERROR(-20010, 'All fields must be provided.');
            END IF;
    
            --CHEDK FOR ANIMAL TO EXISTS
            SELECT COUNT(*)
            INTO   v_count
            FROM   animals
            WHERE  id_animals = p_id_animals;
    
            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20011, 'Invalid animal ID.');
            END IF;
    
            --INSERT
             INSERT INTO medical_info (
                id_animals,
                data_registration,
                birth_date,
                children,
                surgery,
                medication
            ) VALUES (
                p_id_animals,
                p_data_registration,
                p_birth_date,
                p_children,
                p_surgery,
                p_medication
            );
            
            COMMIT;
        EXCEPTION
            
            WHEN dup_val_on_index THEN
                ROLLBACK TO savepoint_add_medical_info;
                RAISE_APPLICATION_ERROR(-20001, 'A medical info with the same id already exists.');
                
            WHEN OTHERS THEN
                ROLLBACK TO savepoint_add_medical_info;
                RAISE_APPLICATION_ERROR(-20002, 'Error when trying to add medical info  to db ' || SQLERRM);

        END;
    END add_medical_info;

     PROCEDURE delete_medical_info (
            p_id_medical IN medical_info.id_medical_info%TYPE
        )
    IS
        v_count    NUMBER;
    BEGIN
        SAVEPOINT savepoint_delete_medical_info;
        
        BEGIN
            IF p_id_medical IS NULL 
            OR p_id_medical = '' THEN
                RAISE_APPLICATION_ERROR(-20001, 'ID MEDICAL INFO type must not be empty.');
            END IF;
            
            SELECT COUNT(*)
            INTO   v_count
            FROM   medical_info
            WHERE  id_medical_info = p_id_medical;

            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20014, 'You are trying to delete an invalid medical info ID .');
            END IF;
            
            DELETE FROM medical_info
            WHERE id_medical_info = p_id_medical;
            
            IF SQL%NOTFOUND THEN
                ROLLBACK TO delete_type_savepoint;
                RAISE_APPLICATION_ERROR(-20004, 'Medical info id ' || p_id_medical || ' not found.');
            END IF;
    
            COMMIT;
        EXCEPTION
             WHEN OTHERS THEN
                    ROLLBACK TO savepoint_delete_medical_info;
                    RAISE_APPLICATION_ERROR(-20005, 'Error in deleting medical info: ' || SQLERRM);
        
        END;
        
     END delete_medical_info;

 PROCEDURE update_medical_info (
        p_id_medical IN medical_info.id_medical_info%TYPE,
        p_choice     IN VARCHAR2,
        p_updated    IN VARCHAR2
    )
    IS
         v_count NUMBER;
         e_no_rows        EXCEPTION;
         e_bad_choice     EXCEPTION;
    BEGIN
        SAVEPOINT savepoint_update_medical_info;
        BEGIN
         IF (p_choice = 'id_animals') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                SELECT COUNT(*)
                INTO v_count
                FROM animals
                WHERE id_animals = TO_NUMBER(p_updated);
                
                IF v_count = 0 THEN
                    RAISE_APPLICATION_ERROR(-20202, 'New id animal type does not exists');
                END IF;  
                
                UPDATE medical_info
                SET id_animals = TO_NUMBER(p_updated)
                WHERE id_medical_info = p_id_medical;
                
        ELSIF (p_choice = 'data_registration') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE medical_info
                SET data_registration = TO_DATE(p_updated, 'dd-mm-yyyy')
                WHERE id_medical_info = p_id_medical;
                
        ELSIF (p_choice = 'birth_date') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE medical_info
                SET birth_date =  TO_DATE(p_updated, 'dd-mm-yyyy')
                WHERE id_medical_info = p_id_medical;
                
        ELSIF (p_choice = 'children') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE medical_info
                SET children = p_updated
                WHERE id_medical_info = p_id_medical;
                
        ELSIF (p_choice = 'surgery') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE medical_info
                SET surgery = p_updated
                WHERE id_medical_info = p_id_medical;
                
        ELSIF (p_choice = 'medication') THEN
                IF p_updated IS NULL THEN
                      RAISE_APPLICATION_ERROR(-20010, 'New value must not be null.');
                END IF;
                
                UPDATE medical_info
                SET medication = p_updated
                WHERE id_medical_info = p_id_medical;
                
        ELSE
            RAISE e_bad_choice;
        END IF;

        IF SQL%NOTFOUND THEN
            RAISE e_no_rows;
        END IF;
        
        COMMIT;
        
        EXCEPTION
            WHEN e_bad_choice THEN
                RAISE_APPLICATION_ERROR(-20201,  'No attribute like ' || p_choice || ' found !');
            WHEN e_no_rows THEN
                RAISE_APPLICATION_ERROR(-20201, 'Medical info with id ' || p_id_medical || ' does not exist.');
            WHEN OTHERS THEN
                ROLLBACK TO savepoint_update_medical_info;
                RAISE_APPLICATION_ERROR(-20002, 'Error in updating ' || p_id_medical || ': ' || SQLERRM);
        
        END;
    END update_medical_info;

    
    
PROCEDURE display_medical_info IS
BEGIN
    FOR rec IN (SELECT *
                FROM medical_info )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Medical Info ID: ' || TO_CHAR(rec.id_medical_info));
        DBMS_OUTPUT.PUT_LINE('Animal ID: ' || TO_CHAR(rec.id_animals));
        DBMS_OUTPUT.PUT_LINE('Data Registration: ' || TO_CHAR(rec.data_registration, 'yyyy-mm-dd'));
        DBMS_OUTPUT.PUT_LINE('Birth Date: ' || TO_CHAR(rec.birth_date, 'yyyy-mm-dd'));
        DBMS_OUTPUT.PUT_LINE('Children: ' || rec.children);
        DBMS_OUTPUT.PUT_LINE('Surgery: ' || rec.surgery);
        DBMS_OUTPUT.PUT_LINE('Medication: ' || rec.medication);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
    END LOOP;
END display_medical_info;


END medical_info_package;
/

ALTER TABLE animals
    ADD CONSTRAINT animal_pen_animals_fk FOREIGN KEY ( id_animal_pen )
        REFERENCES animal_pen ( id_animal_pen )
    NOT DEFERRABLE;

ALTER TABLE animals
    ADD CONSTRAINT animal_type_animals_fk FOREIGN KEY ( id_animal_type )
        REFERENCES animal_type ( id_animal_type )
    NOT DEFERRABLE;

ALTER TABLE animal_info
    ADD CONSTRAINT animals_animal_info FOREIGN KEY ( id_animals )
        REFERENCES animals ( id_animals )
    NOT DEFERRABLE;

ALTER TABLE diet
    ADD CONSTRAINT animals_diet_fk FOREIGN KEY ( id_animals )
        REFERENCES animals ( id_animals )
    NOT DEFERRABLE;

ALTER TABLE medical_info
    ADD CONSTRAINT animals_medical_info_fk FOREIGN KEY ( id_animals )
        REFERENCES animals ( id_animals )
    NOT DEFERRABLE;

ALTER TABLE diet
    ADD CONSTRAINT food_diet_fk FOREIGN KEY ( id_food )
        REFERENCES food ( id_food )
    NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER animal_info_birth_date_check_trg 
    BEFORE INSERT OR UPDATE ON Animal_Info 
    FOR EACH ROW 
    ENABLE 
BEGIN
	IF :new.birth_date > SYSDATE  THEN
	   RAISE_APPLICATION_ERROR(-20001, 'Datele de nastere nu pot fi in viitor.');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER animal_info_gender_check_trg 
    BEFORE INSERT OR UPDATE ON Animal_Info 
    FOR EACH ROW 
BEGIN
    IF UPPER(:new.gender) NOT IN ('MALE', 'FEMALE') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Gender-ul trebuie să fie "Male" sau "Female".');
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER diet_quantity_check_trg 
    BEFORE INSERT OR UPDATE ON Diet 
    FOR EACH ROW 
BEGIN
    IF :new.quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cantitatea mancata de animal pe saptamana trebuie să fie mai mare decât zero.');
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER food_quantity_check_trg 
    BEFORE INSERT OR UPDATE ON Food 
    FOR EACH ROW 
BEGIN
    IF :new.quantity_wk_food <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cantitatea de mancare saptamanala alocata animalelor trebuie să fie mai mare decât zero.');
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER medical_info_date_check_trg 
    BEFORE INSERT ON Medical_Info 
    FOR EACH ROW 
BEGIN
    IF :new.data_registration <= :new.birth_date OR :new.data_registration > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20011, 'Data de înregistrare trebuie să fie ulterioară datei de naștere și să nu fie o dată viitoare.');
    END IF;
END; 
/

CREATE OR REPLACE TRIGGER update_food_quantity_trg 
    AFTER INSERT OR UPDATE ON Diet 
    FOR EACH ROW 
DECLARE
    existing_quantity NUMBER;
    difference NUMBER;
BEGIN
    -- Obține cantitatea existentă din food pentru ID_Food specificat
    SELECT quantity_wk_food 
    INTO existing_quantity
    FROM food
    WHERE id_food = :new.id_food;
    
    -- Calculează diferența dintre noua și vechea cantitate
    difference := NVL(:new.quantity, 0) - NVL(:old.quantity, 0);
    
    -- Verifică dacă cantitatea existentă este suficientă
    IF existing_quantity < ABS(difference) THEN
        RAISE_APPLICATION_ERROR(-20005, 'Cantitatea disponibilă de ' || existing_quantity || ' este insuficientă pentru a adăuga ' || ABS(difference) || '.');
    ELSE
        -- Actualizează cantitatea în tabelul food
        UPDATE food
        SET quantity_wk_food = existing_quantity - difference
        WHERE id_food = :new.id_food;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, 'ID_Food nu există în tabelul food.');
END; 
/


CREATE SEQUENCE animal_info_id_animals_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER animal_info_id_animals_trg BEFORE
    INSERT ON animal_info
    FOR EACH ROW
    WHEN ( new.id_animals IS NULL )
BEGIN
    :new.id_animals := animal_info_id_animals_seq.nextval;
END;
/

CREATE SEQUENCE animal_pen_id_animal_pen_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER animal_pen_id_animal_pen_trg BEFORE
    INSERT ON animal_pen
    FOR EACH ROW
    WHEN ( new.id_animal_pen IS NULL )
BEGIN
    :new.id_animal_pen := animal_pen_id_animal_pen_seq.nextval;
END;
/

CREATE SEQUENCE animal_type_id_animal_type_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER animal_type_id_animal_type_trg BEFORE
    INSERT ON animal_type
    FOR EACH ROW
    WHEN ( new.id_animal_type IS NULL )
BEGIN
    :new.id_animal_type := animal_type_id_animal_type_seq.nextval;
END;
/

CREATE SEQUENCE animals_id_animals_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER animals_id_animals_trg BEFORE
    INSERT ON animals
    FOR EACH ROW
    WHEN ( new.id_animals IS NULL )
BEGIN
    :new.id_animals := animals_id_animals_seq.nextval;
END;
/

CREATE SEQUENCE diet_id_diet_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER diet_id_diet_trg BEFORE
    INSERT ON diet
    FOR EACH ROW
    WHEN ( new.id_diet IS NULL )
BEGIN
    :new.id_diet := diet_id_diet_seq.nextval;
END;
/

CREATE SEQUENCE food_id_food_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER food_id_food_trg BEFORE
    INSERT ON food
    FOR EACH ROW
    WHEN ( new.id_food IS NULL )
BEGIN
    :new.id_food := food_id_food_seq.nextval;
END;
/

CREATE SEQUENCE medical_info_id_medical_info START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER medical_info_id_medical_info BEFORE
    INSERT ON medical_info
    FOR EACH ROW
    WHEN ( new.id_medical_info IS NULL )
BEGIN
    :new.id_medical_info := medical_info_id_medical_info.nextval;
END;
/