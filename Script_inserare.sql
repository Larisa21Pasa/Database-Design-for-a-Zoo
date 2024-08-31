BEGIN
    animal_pen_package.add_animal_pen('PEN Arachnids');
    animal_pen_package.add_animal_pen('PEN Bird');
    animal_pen_package.add_animal_pen('PEN Canine');
    animal_pen_package.add_animal_pen('PEN Fish');
    animal_pen_package.add_animal_pen('PEN Feline');
    animal_pen_package.add_animal_pen('PEN Rodent');
    animal_pen_package.add_animal_pen('PEN Insect');
    animal_pen_package.add_animal_pen('PEN Reptiles');
    
    COMMIT; 
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error in inserting pen: ' || SQLERRM);
END;
/




BEGIN
    animal_type_package.add_animal_type('Arachnids');
    animal_type_package.add_animal_type('Bird');
    animal_type_package.add_animal_type('Canine');
    animal_type_package.add_animal_type('Fish');
    animal_type_package.add_animal_type('Feline');
    animal_type_package.add_animal_type('Rodent');
    animal_type_package.add_animal_type('Insect');
    animal_type_package.add_animal_type('Reptiles');
    
    COMMIT; 
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error in adding animal types: ' || SQLERRM);
END;
/






BEGIN
    animals_package.add_animal(3, 3, 'Elias', TO_DATE('2021-11-25', 'YYYY-MM-DD'), 'Male');
    animals_package.add_animal(8, 8, 'Alla', TO_DATE('2015-02-03', 'YYYY-MM-DD'), 'Male');
    animals_package.add_animal(4, 4, 'Enob', TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Female');
    animals_package.add_animal(1, 1, 'Cally', TO_DATE('2017-09-04', 'YYYY-MM-DD'), 'Female');
    animals_package.add_animal(5, 3, 'Callynoe', TO_DATE('2017-09-04', 'YYYY-MM-DD'), 'Male');
    animals_package.add_animal(5, 5, 'Liam', TO_DATE('2001-08-13', 'YYYY-MM-DD'), 'Male');
    animals_package.add_animal(1, 1, 'Liam', TO_DATE('2015-07-10', 'YYYY-MM-DD'), 'Male');
   -- animals_package.add_animal(2, 2, 'Charlotte', TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Female');
    animals_package.add_animal(3, 3, 'Oliver', TO_DATE('2017-09-04', 'YYYY-MM-DD'), 'Female');
    animals_package.add_animal(5, 5, 'Elijah', TO_DATE('2017-09-04', 'YYYY-MM-DD'), 'Male');
    animals_package.add_animal(1, 1, 'Henry', TO_DATE('2012-04-24', 'YYYY-MM-DD'), 'Male');
    animals_package.add_animal(1, 1, 'Mia', TO_DATE('2016-02-03', 'YYYY-MM-DD'), 'Male');
    --animals_package.add_animal(2, 2, 'Evelyn', TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Female');
    animals_package.add_animal(3, 3, 'Calios', TO_DATE('2017-10-10', 'YYYY-MM-DD'), 'Female');
    animals_package.add_animal(5, 5, 'Balla', TO_DATE('2017-03-04', 'YYYY-MM-DD'), 'Male');
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error in adding animal types: ' || SQLERRM);
END;
/







BEGIN
    medical_info_package.add_medical_info(1, TO_DATE('2022-11-25', 'YYYY-MM-DD'), TO_DATE('2021-11-25', 'YYYY-MM-DD'), 'No', 'No surgery yet', 'Paracetamol');
    medical_info_package.add_medical_info(2, TO_DATE('2022-10-19', 'YYYY-MM-DD'), TO_DATE('2015-02-03', 'YYYY-MM-DD'), 'Yes', 'No surgery yet', 'E Vitamin');
    medical_info_package.add_medical_info(3, TO_DATE('2022-09-09', 'YYYY-MM-DD'), TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Yes', 'Unknown', 'C Vitamin');
    medical_info_package.add_medical_info(4, TO_DATE('2022-01-06', 'YYYY-MM-DD'), TO_DATE('2017-09-04', 'YYYY-MM-DD'), 'Yes', 'No surgery yet', 'D Vitamin');
    medical_info_package.add_medical_info(5, TO_DATE('2021-10-23', 'YYYY-MM-DD'), TO_DATE('2017-09-04', 'YYYY-MM-DD'), 'No', 'Pif surgery', 'Immunosuppressive');
    medical_info_package.add_medical_info(5, TO_DATE('2021-09-19', 'YYYY-MM-DD'), TO_DATE('2017-09-04', 'YYYY-MM-DD'), 'Yes', 'No surgery yet', 'E Vitamin');
    medical_info_package.add_medical_info(8, TO_DATE('2020-09-01', 'YYYY-MM-DD'), TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Yes', 'Caesarean', 'None');
    medical_info_package.add_medical_info(8, TO_DATE('2020-01-01', 'YYYY-MM-DD'), TO_DATE('2010-08-03', 'YYYY-MM-DD'), 'Yes', 'No surgery yet', 'D Vitamin');

    COMMIT; 
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error in inserting medical info: ' || SQLERRM);
END;
/





BEGIN
    food_package.add_food('corn', 200);
    food_package.add_food('oat', 100);
    food_package.add_food('meat', 500);
    food_package.add_food('grass', 50);
    food_package.add_food('insects', 20);
    food_package.add_food('leaves', 700);
    food_package.add_food('frogs', 500);
    food_package.add_food('grains', 100);
    food_package.add_food('worms', 100);
    food_package.add_food('honey', 100);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error in adding food: ' || SQLERRM);
END;
/




BEGIN
    diet_package.add_diet(3, 1, 'Omnivor', 50);
    diet_package.add_diet(5, 2, 'Omnivor', 10);
    diet_package.add_diet(9, 2, 'Omnivor', 3);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error in adding diet: ' || SQLERRM);
END;
/



SELECT * FROM animal_type;
SELECT * FROM animals;
SELECT * FROM animal_info;
SELECT * FROM medical_info;
SELECT * FROM food;
SELECT * FROM diet;





