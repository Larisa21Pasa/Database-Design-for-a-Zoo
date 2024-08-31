-------------------------- TEST TRIGGERI --------------------------------------------------

-------------------------- START TEST animal_info_birth_date_check_trg --------------------
select * from animal_info;

UPDATE animal_info
SET birth_date = TO_DATE('2025-06-01', 'yyyy-mm-dd')
WHERE id_animals = 1;
-------------------------- STOP TEST animal_info_birth_date_check_trg --------------------


-------------------------- START TEST food_quantity_check_trg --------------------
select * from food;

INSERT INTO food (Food_Type, Quantity_wk_food) VALUES ('mushrooms', 0); 
-------------------------- STOP TEST food_quantity_check_trg --------------------



-------------------------- START TEST diet_quantity_check_trg --------------------
insert into diet (ID_Food,ID_Animals,Diet_Type, Quantity ) values(9,2,'Omnivor',-8);

-------------------------- STOP TEST diet_quantity_check_trg --------------------



-------------------------- START TEST animal_info_gender_check_trg --------------------
UPDATE animal_info
SET gender = 'Unknown'
WHERE id_animals = 1;
-------------------------- STOP TEST animal_info_gender_check_trg --------------------




-------------------------- START TEST update_food_quantity_trg --------------------
select * from food;
select * from animals;

    

-- EXEMPLU DE TRANZACTIE COMPLETA IN CARE SURPRIND MODIFICARILE TABELEI FOOD 
-- EXEMPLU REALIZAT PENTRU TIPUL DE ANIMAL PASARE, CU TIPUL DE MANCARE <INSECTS>
DECLARE
    v_food_insects_quantity NUMBER := 0;
    v_type_animal NUMBER := 2;
    v_type_food NUMBER := 5; -- insects

    v_number_birds NUMBER;
    v_charlotte_id NUMBER;
    v_evelyn_id NUMBER;
    
    v_charlotte_diet_id NUMBER;
    v_evelyn_diet_id NUMBER;
BEGIN
    -- ADD ONLY 2 BIRDS FOR MORE CONTROL OF THIS EXAMPLE
    animals_package.add_animal(2, 2, 'Charlotte', TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Female');
    SELECT id_animals INTO v_charlotte_id FROM animal_info WHERE name = 'Charlotte' AND ROWNUM = 1;

    animals_package.add_animal(2, 2, 'Evelyn', TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Female');
    SELECT id_animals INTO v_evelyn_id FROM animal_info WHERE name = 'Evelyn' AND ROWNUM = 1;
     
    -- DISPLAY ANIMALS 
    DBMS_OUTPUT.PUT_LINE('Displaying animal_info after adding 2 birds:');
    animals_package.display_animal_info;
    
    DBMS_OUTPUT.PUT_LINE('Want to add these 2 birds to diet with insects food.');
    food_package.display_food; -- 10 kg by default
     
    
    DBMS_OUTPUT.PUT_LINE('So add Charlotte to diet with 2 kg insects per week');
    diet_package.add_diet(v_type_food, v_charlotte_id, 'Omnivor', 2);
    
    SELECT id_diet INTO v_charlotte_diet_id 
    FROM diet 
    WHERE id_animals = v_charlotte_id AND id_food = v_type_food AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Now should see insects quantity with 8.');
    food_package.display_food;
    
    DBMS_OUTPUT.PUT_LINE('Add Evelyn to diet with 3 kg insects per week');
    diet_package.add_diet(v_type_food, v_evelyn_id, 'Omnivor', 3);
    
    SELECT id_diet INTO v_evelyn_diet_id 
    FROM diet 
    WHERE id_animals = v_evelyn_id AND id_food = v_type_food AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Now should see insects quantity with 5.');
    food_package.display_food;
    
    
    DBMS_OUTPUT.PUT_LINE('Charlotte  changes to diet with 3 kg insects per week');
    diet_package.update_diet(v_charlotte_diet_id, 'quantity', 3);
    
    DBMS_OUTPUT.PUT_LINE('Now should see insects quantity with 4 ( 5 preceeded and minus 1 from Charlote increases).');
    food_package.display_food;
    
    
    DBMS_OUTPUT.PUT_LINE('Evelyn  changes to diet with 1 kg insects per week');
    diet_package.update_diet(v_evelyn_diet_id, 'quantity', 1);
    
    DBMS_OUTPUT.PUT_LINE('Now should see insects quantity with 6( 4 preceed and 2 from initial 3 kg from Evelyn).');
    food_package.display_food;
    
    
    COMMIT;

END;

-------------------------- STOP TEST update_food_quantity_trg --------------------




-------------------------- START TEST medical_info_date_check_trg --------------------

-- Inserare cu data de înregistrare anterioară datei de naștere
INSERT INTO medical_info (ID_Animals, Data_Registration, Birth_Date, Children, Surgery, Medication)
VALUES (1, TO_DATE('2021-11-25', 'yyyy-mm-dd'), TO_DATE('2022-11-25', 'yyyy-mm-dd'), 'No', 'No surgery yet', 'Paracetamol');
-- Aceasta ar trebui să arunce o eroare, deoarece data de înregistrare este anterioară datei de naștere

-- Inserare cu data de înregistrare ulterioară datei de naștere și nu o dată viitoare
INSERT INTO medical_info (ID_Animals, Data_Registration, Birth_Date, Children, Surgery, Medication)
VALUES (2, TO_DATE('2022-10-19', 'yyyy-mm-dd'), TO_DATE('2015-02-03', 'yyyy-mm-dd'), 'Yes', 'No surgery yet', 'E Vitamin');
-- Aceasta ar trebui să funcționeze fără probleme, deoarece datele sunt corecte

-- Inserare cu data de înregistrare viitoare
INSERT INTO medical_info (ID_Animals, Data_Registration, Birth_Date, Children, Surgery, Medication)
VALUES (3, TO_DATE('2024-09-09', 'yyyy-mm-dd'), TO_DATE('2010-08-03', 'yyyy-mm-dd'), 'Yes', 'Unknown', 'C Vitamin');
-- Aceasta ar trebui să arunce o eroare, deoarece data de înregistrare este o dată viitoare

-------------------------- STOP TEST medical_info_date_check_trg --------------------


----------------------------------- START TEST PROCEDURE ANIMAL PEN ----------------------------------
-- CLEAN TABLE
DELETE FROM animal_pen where id_animal_pen >= 1;

select * from animal_pen;



-- TEST INSERT
CREATE OR REPLACE PROCEDURE test_insert_and_display AS
    v_count NUMBER;

BEGIN
    animal_pen_package.add_animal_pen('PEN LALALA');
   
    animal_pen_package.display_animal_pen;
    
    SELECT COUNT(*)INTO v_count FROM animal_pen WHERE name_pen = 'PEN LALALA';
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('PEN LALALA was inserted.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('PEN LALALA was not inserted.');
    END IF;
END test_insert_and_display;
/

BEGIN
     test_insert_and_display;
END;


-- TEST DELETE
CREATE OR REPLACE PROCEDURE test_delete_and_display AS
    v_count NUMBER;

BEGIN
    -- DELETE -> BE SURE TO NOT USE THIS ID AS FK IN ANIMALS -> ERROR CONSTRAINT INTEGRITY ANIMAL_PEN_ANIMALS_FK
    animal_pen_package.delete_animal_pen('PEN LALALA');
    animal_pen_package.display_animal_pen;
    
    SELECT COUNT(*) INTO v_count FROM animal_pen WHERE name_pen = 'PEN LALALA';

     IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('PEN LALALA was deleted.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('PEN LALALA was not deleted.');
    END IF;
END test_delete_and_display;
/

BEGIN
 test_delete_and_display;
END;

-- TEST UPDATE
CREATE OR REPLACE PROCEDURE test_update_and_display AS
    v_count NUMBER;

BEGIN
    animal_pen_package.update_animal_pen(1, 'name_pen', 'PEN Arachnids Updated');
    
    animal_pen_package.display_animal_pen;
    
    SELECT COUNT(*) INTO v_count FROM animal_pen WHERE name_pen = 'PEN Arachnids Updated';
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('PEN Arachnids Updated was updated.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('PEN Arachnids Updated was not updated.');
    END IF;
END test_update_and_display;
/

BEGIN
 test_update_and_display;
END;

----------------------------------- STOP TEST PROCEDURE ANIMAL PEN ----------------------------------






----------------------------------- START TEST PROCEDURE ANIMAL TYPE ----------------------------------
select * from animal_type;

-- current type allowed:  'Arachnids', 'Bird', 'Canine', 'Feline', 'Fish', 'Insect', 'Reptiles', 'Rodent'.
-- by default i inserted all types. now i will delete one and try inser procedure
delete from animal_type where id_animal_type=6; --rodent is not used in default insert

-- TEST INSERT
CREATE OR REPLACE PROCEDURE test_insert_animal_type_and_display AS
    v_count NUMBER;

BEGIN
    animal_type_package.add_animal_type('Rodent');
   
    animal_type_package.display_animal_type;
  
END test_insert_animal_type_and_display;
/

BEGIN
     test_insert_animal_type_and_display;
END;
/



-- TEST DELETE
CREATE OR REPLACE PROCEDURE test_delete_and_display AS
v_count NUMBER;
BEGIN
    -- DELETE -> BE SURE TO NOT USE THIS ID AS FK IN ANIMALS -> ERROR CONSTRAINT INTEGRITY ANIMAL_PEN_ANIMALS_FK
    animal_type_package.delete_animal_type('Rodent');
    
    animal_type_package.display_animal_type;
    
    SELECT COUNT(*) INTO v_count FROM ANIMAL_TYPE WHERE type_animal = 'Rodent';
    
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Rodent was deleted.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Rodent was not deleted.');
    END IF;
END test_delete_and_display;
/

BEGIN
 test_delete_and_display;
END;



-- TEST UPDATE
CREATE OR REPLACE PROCEDURE test_update_and_display AS
    v_count NUMBER;

BEGIN
    animal_type_package.update_animal_type(2, 'type_animal', 'Rodent'); --FROM LIST 
    
    animal_type_package.display_animal_type;
    
    SELECT COUNT(*) INTO v_count FROM ANIMAL_TYPE WHERE type_animal = 'Rodent';
    
    IF v_count > 1 THEN
        DBMS_OUTPUT.PUT_LINE('Bird to Rodent which is not in table was updated.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Bird to Rodent which is not in table was not updated.');
    END IF;
END test_update_and_display;
/

BEGIN
 test_update_and_display;
END;
----------------------------------- STOP TEST PROCEDURE ANIMAL TYPE ----------------------------------








----------------------------------- START TEST PROCEDURE ANIMALS  ----------------------------------
select * from animals;
select * from animal_info;

-- INSERT OK
CREATE OR REPLACE PROCEDURE test_add_animal_valid AS
BEGIN
    animals_package.add_animal(1, 1, 'TestAnimal', '01-01-2020', 'Male');
    
   
   DBMS_OUTPUT.PUT_LINE('Displaying animals after adding:');
    animals_package.display_animal;
    
    DBMS_OUTPUT.PUT_LINE('Displaying animal_info after adding:');
    animals_package.display_animal_info;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_add_animal_valid;
/

BEGIN
    test_add_animal_valid;
END;


-- INSERT WITH NULL PARAMETER
CREATE OR REPLACE PROCEDURE test_add_animal_missing_fields AS
BEGIN
    animals_package.add_animal(NULL, 1, 'TestAnimal', '01-01-2020', 'Male');
    DBMS_OUTPUT.PUT_LINE('Attempted to add an animal with missing required fields.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_add_animal_missing_fields;
/

BEGIN
    test_add_animal_missing_fields;
    --Error: ORA-20002: Error when trying to add animal  to db ORA-20001: 
    --All fields must be provided.
END;

--INVALID ANIMAL TYPE
CREATE OR REPLACE PROCEDURE test_add_invalid_animal_type AS
BEGIN
    animals_package.add_animal(999, 1, 'TestAnimal', '01-01-2020', 'Male');
    DBMS_OUTPUT.PUT_LINE('Attempted to add an animal with an invalid animal type ID.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_add_invalid_animal_type;
/

BEGIN
    test_add_invalid_animal_type;
    --Error: ORA-20002: Error when trying to add animal  to db ORA-20011:
    --Invalid animal type ID.
END;

-- DELETE
CREATE OR REPLACE PROCEDURE test_delete_animal_valid AS
BEGIN
    -- Assume an animal with ID 1 exists for testing
    animals_package.delete_animal(1);
    
    DBMS_OUTPUT.PUT_LINE('Displaying animals after deleting:');
    animals_package.display_animal;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_delete_animal_valid;
/

BEGIN
    test_delete_animal_valid;
END;

-- INVALID DELETE
CREATE OR REPLACE PROCEDURE test_delete_invalid_animal AS
BEGIN
    animals_package.delete_animal(999);
    DBMS_OUTPUT.PUT_LINE('Attempted to delete an invalid animal ID.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_delete_invalid_animal;
/

BEGIN
    test_delete_invalid_animal;
    --Error: ORA-20020: Error in deleting animal: ORA-20004: 
    --You are trying to delete an invalid animal ID.
END;


-- UPDATE
CREATE OR REPLACE PROCEDURE test_update_animal_valid AS
BEGIN
    animals_package.update_animal(2, 'name', 'UpdatedName');
  
    DBMS_OUTPUT.PUT_LINE('Displaying animals after update:');
    animals_package.display_animal_info;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_update_animal_valid;
/

BEGIN
    test_update_animal_valid;
END;


-- INVALID UPDATE
CREATE OR REPLACE PROCEDURE test_update_invalid_animal AS
BEGIN
    animals_package.update_animal(999, 'name', 'UpdatedName');
  
    DBMS_OUTPUT.PUT_LINE('Displaying animals after update:');
    animals_package.display_animal_info;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_update_invalid_animal;
/

BEGIN
    test_update_invalid_animal;
    --Error: ORA-20201: Animal with id 999 does not exists.
END;
----------------------------------- STOP TEST PROCEDURE ANIMALS ----------------------------------






----------------------------------- START TEST PROCEDURE MEDICAL  ----------------------------------
select * from medical_info;

--INSERT
CREATE OR REPLACE PROCEDURE test_add_medical_info_valid AS
BEGIN
    medical_info_package.add_medical_info(2, SYSDATE, '01-01-2020', 'No', 'None', 'None');
    
    DBMS_OUTPUT.PUT_LINE('Displaying medical_info after adding:');
    medical_info_package.display_medical_info;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_add_medical_info_valid;
/

BEGIN
test_add_medical_info_valid;
END;

--DELETE
CREATE OR REPLACE PROCEDURE test_delete_medical_info_valid AS
BEGIN
    -- Assume a medical_info with ID 1 exists for testing
    medical_info_package.delete_medical_info(2);
    
    DBMS_OUTPUT.PUT_LINE('Displaying medical_info after deleting:');
    medical_info_package.display_medical_info;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_delete_medical_info_valid;
/

BEGIN
test_delete_medical_info_valid;
END;


--UPDATE
CREATE OR REPLACE PROCEDURE test_update_medical_info_valid AS
BEGIN
    medical_info_package.update_medical_info(3, 'surgery', 'UpdatedSurgery');
    
    DBMS_OUTPUT.PUT_LINE('Displaying medical_info after updating:');
    medical_info_package.display_medical_info;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_update_medical_info_valid;
/

BEGIN
test_update_medical_info_valid;
END;
----------------------------------- STOP TEST PROCEDURE MEDICAL  ----------------------------------








----------------------------------- START TEST PROCEDURE FOOD  ----------------------------------
SELECT * FROM FOOD;

--INSERT
CREATE OR REPLACE PROCEDURE test_add_food_valid AS
BEGIN
    food_package.add_food('tomato', 50);
    DBMS_OUTPUT.PUT_LINE('Displaying food after adding:');
    food_package.display_food;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_add_food_valid;
/

BEGIN
    test_add_food_valid;
END;

--DELETE
CREATE OR REPLACE PROCEDURE test_delete_food_valid AS
BEGIN
    food_package.delete_food(1);
    DBMS_OUTPUT.PUT_LINE('Displaying food after deleting:');
    food_package.display_food;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_delete_food_valid;
/

BEGIN
    test_delete_food_valid;
END;

-- UPDATE
CREATE OR REPLACE PROCEDURE test_update_food_valid AS
BEGIN
    food_package.update_food(2, 'food_type', 'UpdatedGrass');
    DBMS_OUTPUT.PUT_LINE('Displaying food after update:');
    food_package.display_food;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_update_food_valid;
/

BEGIN
    test_update_food_valid;
END;


----------------------------------- STOP TEST PROCEDURE FOOD  ----------------------------------






----------------------------------- START TEST PROCEDURE DIET  ----------------------------------
SELECT * FROM ANIMALS;
SELECT * FROM ANIMAL_INFO;

SELECT * FROM FOOD;
SELECT * FROM DIET;

-- INSERT VALID
CREATE OR REPLACE PROCEDURE test_add_diet_valid AS
BEGIN
    diet_package.add_diet(2, 1, 'Omnivor', 50);
    
    DBMS_OUTPUT.PUT_LINE('Displaying diet after adding:');
    diet_package.display_diet;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_add_diet_valid;
/

BEGIN
    test_add_diet_valid;
END;

-- DELETE
CREATE OR REPLACE PROCEDURE test_delete_diet_valid AS
BEGIN
    diet_package.delete_diet(7);
    
    DBMS_OUTPUT.PUT_LINE('Displaying diet after deleting:');
    diet_package.display_diet;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_delete_diet_valid;
/

BEGIN
    test_delete_diet_valid;
END;

-- UPDATE
CREATE OR REPLACE PROCEDURE test_update_diet_valid AS
BEGIN
    diet_package.update_diet(4, 'diet_type', 'Carnivor');
  
    DBMS_OUTPUT.PUT_LINE('Displaying diet after update:');
    diet_package.display_diet;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END test_update_diet_valid;
/

BEGIN
    test_update_diet_valid;
END;

----------------------------------- STOP TEST PROCEDURE DIET  ----------------------------------










