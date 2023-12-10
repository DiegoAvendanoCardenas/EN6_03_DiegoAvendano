--EN6 | Programación PL/SQL--

  -- En cuanto al curso de PL/SQL en cuanto a los proyectos x por integrante de equipo:
  -- procedimientos almacenados por integrante de equipo
  -- Funciones de usuario o personalizadas por integrante
  -- Excepciones y manejo de errores
  -- packages
  -- trigers

-- 2 procedimientos almacenados por integrante de equipo

CREATE OR REPLACE PROCEDURE INSERT_STUDENT(
    P_NAMES VARCHAR2,
    P_SURNAME VARCHAR2,
    P_DOCUMENT_TYPE CHAR,
    P_DOCUMENT_NUMBER VARCHAR2,
    P_DIRECTION VARCHAR2,
    P_EMAIL VARCHAR2,
    P_CELL_PHONE CHAR,
    P_ID_YEAR NUMBER,
    P_ID_SECTION NUMBER
) AS
BEGIN
    INSERT INTO STUDENT (
        NAMES,
        SURNAME,
        DOCUMENT_TYPE,
        DOCUMENT_NUMBER,
        DIRECTION,
        EMAIL,
        CELL_PHONE,
        ID_YEAR,
        ID_SECTION
    ) VALUES (
        P_NAMES,
        P_SURNAME,
        P_DOCUMENT_TYPE,
        P_DOCUMENT_NUMBER,
        P_DIRECTION,
        P_EMAIL,
        P_CELL_PHONE,
        P_ID_YEAR,
        P_ID_SECTION
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Estudiante creado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END INSERT_STUDENT;
/


-- Ejemplo para el procedimiento INSERT_STUDENT
BEGIN
  INSERT_STUDENT('Nombre', 'Apellido', 'DNI', '44345670', 'prueba', 'coro@dominio.com','914543421',1, 1);
END;
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UPDATE_STUDENT(
    P_ID_STUDENT NUMBER,
    P_NAMES VARCHAR2,
    P_SURNAME VARCHAR2,
    P_DOCUMENT_TYPE CHAR,
    P_DOCUMENT_NUMBER VARCHAR2,
    P_DIRECTION VARCHAR2,
    P_EMAIL VARCHAR2,
    P_CELL_PHONE CHAR,
    P_ID_YEAR NUMBER,
    P_ID_SECTION NUMBER
) AS
BEGIN
    UPDATE STUDENT
    SET
        NAMES = P_NAMES,
        SURNAME = P_SURNAME,
        DOCUMENT_TYPE = P_DOCUMENT_TYPE,
        DOCUMENT_NUMBER = P_DOCUMENT_NUMBER,
        DIRECTION = P_DIRECTION,
        EMAIL = P_EMAIL,
        CELL_PHONE = P_CELL_PHONE,
        ID_YEAR = P_ID_YEAR,
        ID_SECTION = P_ID_SECTION
    WHERE ID_STUDENT = P_ID_STUDENT;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Estudiante actualizado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END UPDATE_STUDENT;

-- Ejemplo para el procedimiento UPDATE_STUDENT
BEGIN
    UPDATE_STUDENT(
        P_ID_STUDENT => 1,  
        P_SURNAME => 'ARBIETO CONTRERAS', 
        P_NAMES => 'AMIR ANDER',
        P_DOCUMENT_TYPE => 'DNI',
        P_DOCUMENT_NUMBER => '73323346',
        P_DIRECTION => 'JR PERU',
        P_EMAIL => 'amir@gmail.com',
        P_CELL_PHONE => '985210011',
        P_ID_YEAR => 1,
        P_ID_SECTION => 1
    );
END;



-- Procedimiento DELETE_STUDENT
CREATE OR REPLACE PROCEDURE DELETE_STUDENT(
    P_ID_STUDENT NUMBER
) AS
BEGIN
    UPDATE STUDENT
    SET STATES = 'I'
    WHERE ID_STUDENT = P_ID_STUDENT;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Estudiante eliminado logicamente correctamente');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontro el estudiante con el ID:' || P_ID_STUDENT);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        ROLLBACK;
END DELETE_STUDENT;
/

-- Ejemplo para el procedimiento DELETE_STUDENT
BEGIN
    DELETE_STUDENT(P_ID_STUDENT => 1);
END;
/

--  Funciones de usuario o personalizadas por integrante

-- Obtener la lista de estudiantes por estado
CREATE OR REPLACE FUNCTION get_students_by_state(p_state VARCHAR2)
RETURN SYS_REFCURSOR
AS
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT *
    FROM STUDENT
    WHERE states = p_state;

  RETURN v_cursor;
END;
/

-- Ejemplo de uso:
DECLARE
  student_cursor SYS_REFCURSOR;
  student_record STUDENT%ROWTYPE;
BEGIN
  student_cursor := get_students_by_state('A');
  LOOP
    FETCH student_cursor INTO student_record;
    EXIT WHEN student_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('ID: ' || student_record.id_student || ', Nombre: ' || student_record.names);
  END LOOP;
  CLOSE student_cursor;
END;


-- Obtener la lista de estudiantes asignados a un id_year y id_section
CREATE OR REPLACE FUNCTION get_students_by_id_year_and_section(
    p_id_year NUMBER,
    p_id_section NUMBER
)
RETURN SYS_REFCURSOR
AS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT *
        FROM STUDENT
        WHERE id_year = p_id_year
          AND id_section = p_id_section;

    RETURN v_cursor;
END;
/

-- Ejemplo de uso:
DECLARE
    student_cursor SYS_REFCURSOR;
    student_record STUDENT%ROWTYPE;
BEGIN                                                           
    student_cursor := get_students_by_id_year_and_section(1, 1); -- ID_YEAR, ID_SECTION
    LOOP
        FETCH student_cursor INTO student_record;
        EXIT WHEN student_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || student_record.id_student || ', Nombre: ' || student_record.names || ', ' || student_record.surname);
    END LOOP;
    CLOSE student_cursor;
END;


---  Excepciones y manejo de errores


-- Ejemplo 1: Manejo de errores por duplicado de documento_number en STUDENT
DECLARE
    duplicate_document_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(duplicate_document_exception, -1);
BEGIN
    INSERT INTO STUDENT (
        names, surname, document_type, document_number, cell_phone, email, direction, id_year, id_section,states
    )
    VALUES (
        'GARCIA', 'JUAN', 'DNI', '12345678', '987654321', 'juan@gmail.com', 'JR puno 12', 1, 1, 'A'
    );
EXCEPTION
    WHEN duplicate_document_exception THEN
        DBMS_OUTPUT.PUT_LINE('Error: Violación de la restricción UNIQUE en el campo DOCUMENT_NUMBER.');
END;
--------------------------------------------------------------------------------
-- Ejemplo 2: Manejo de errores por longitud incorrecta del número de teléfono en STUDENT
DECLARE
    invalid_phone_length_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_phone_length_exception, -1);
    v_cell_phone VARCHAR2(9 CHAR) := '987654321'; -- Ajustar el número de teléfono a la longitud permitida
BEGIN
    INSERT INTO STUDENT (
        surname, names, document_type, document_number, cell_phone, email, direction, id_year, id_section, states
    )
    VALUES (
        'GARCIA', 'JUAN', 'DNI', '98765432', v_cell_phone, 'juan@gmail.com', 'jR CUZCO 2', 1, 1, 'A'
    );
EXCEPTION
    WHEN invalid_phone_length_exception THEN
        DBMS_OUTPUT.PUT_LINE('Error: La longitud del número de teléfono no cumple con la restricción.');
END;
--------------------------------------------------------------------------------
-- Ejemplo 3: Manejo de errores por referencia a un id_year inexistente en STUDENT
DECLARE
    invalid_id_year_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_id_year_exception, -1);
BEGIN
    INSERT INTO STUDENT (
        surname, names, document_type, document_number, cell_phone, email, direction, id_year, id_section,states
    )
    VALUES (
        'GARCIA', 'JUAN', 'DNI', '98765432', '987654321', 'juan@gmail.com', 'A1', 2, 1,'A'
    );
EXCEPTION
    WHEN invalid_id_year_exception THEN
        DBMS_OUTPUT.PUT_LINE('Error: Violación de la restricción FOREIGN KEY en el campo ID_YEAR.');
END;
--------------------------------------------------------------------------------
-- Ejemplo 4: Manejo de errores por referencia a un id_section inexistente en STUDENT
DECLARE
    invalid_id_section_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_id_section_exception, -1);
BEGIN
    INSERT INTO STUDENT (
        surname, names, document_type, document_number, cell_phone, email, direction, id_year, id_section, states
    )
    VALUES (
        'GARCIA', 'JUAN', 'DNI', '98765432', '987654321', 'juan@gmail.com', 'A1', 999, 1,'A'
    );
EXCEPTION
    WHEN invalid_id_section_exception THEN
        DBMS_OUTPUT.PUT_LINE('Error: Violación de la restricción FOREIGN KEY en el campo ID_Section.');
END;
/

--2 packages

-- Crear el paquete student_query_pkg
CREATE OR REPLACE PACKAGE student_query_pkg AS
    FUNCTION get_students_by_year(
        p_id_year NUMBER
    ) RETURN SYS_REFCURSOR;

    FUNCTION get_students_by_section(
        p_id_section VARCHAR2
    ) RETURN SYS_REFCURSOR;
END student_query_pkg;
/


-- Crear el cuerpo del paquete
CREATE OR REPLACE PACKAGE BODY student_query_pkg AS
    FUNCTION get_students_by_year(
        p_id_year NUMBER
    ) RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        SELECT id_section, surname || ', ' || names AS student_name
        FROM STUDENT WHERE id_year = p_id_year;
        RETURN v_cursor;
    END get_students_by_year;

    FUNCTION get_students_by_section(
        p_id_section VARCHAR2
    ) RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        SELECT id_student, surname || ', ' || names AS student_name
        FROM STUDENT WHERE id_section = p_id_section;
        RETURN v_cursor;
    END get_students_by_section;
END student_query_pkg;
/

-- Bloque de código que utiliza el paquete
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id_student NUMBER;
    v_student_name VARCHAR2(100);
BEGIN
    -- Uso del paquete para obtener estudiantes por Año
    v_cursor := student_query_pkg.get_students_by_year(1);

    -- Recorrer el cursor y realizar operaciones con los datos
    LOOP
        FETCH v_cursor INTO v_id_student, v_student_name;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Realizar operaciones con los datos del estudiante
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_id_student);
        DBMS_OUTPUT.PUT_LINE('Student Name: ' || v_student_name);
    END LOOP;

    -- Cerrar el cursor cuando hayas terminado
    CLOSE v_cursor;
END;

-- Crear el paquete
CREATE OR REPLACE PACKAGE student_info_pkg AS
    FUNCTION get_active_students RETURN SYS_REFCURSOR;
    FUNCTION get_students_by_section(p_id_section VARCHAR2) RETURN SYS_REFCURSOR;
END student_info_pkg;
/

-- Crear el cuerpo del paquete
CREATE OR REPLACE PACKAGE BODY student_info_pkg AS
    FUNCTION get_active_students RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        SELECT id_student, surname, names
        FROM STUDENT
        WHERE states = 'A';
        RETURN v_cursor;
    END get_active_students;

    FUNCTION get_students_by_section(p_id_section VARCHAR2) RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        SELECT id_student, surname, names
        FROM STUDENT
        WHERE id_section = p_id_section;
        RETURN v_cursor;
    END get_students_by_section;
END student_info_pkg;
/
-- Bloque de código que utiliza el paquete
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id_student NUMBER;
    v_surname VARCHAR2(40);
    v_names VARCHAR2(40);
BEGIN
    -- Uso del paquete para obtener estudiantes activos
    v_cursor := student_info_pkg.get_active_students;

    -- Recorrer el cursor y mostrar los datos
    DBMS_OUTPUT.PUT_LINE('Active Students:');
    LOOP
        FETCH v_cursor INTO v_id_student, v_surname, v_names;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Mostrar datos del estudiante
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_id_student);
        DBMS_OUTPUT.PUT_LINE('Student Name: ' || v_surname|| ' ' || v_names);
    END LOOP;

    -- Cerrar el cursor cuando hayas terminado
    CLOSE v_cursor;

    -- Uso del paquete para obtener estudiantes por sección
    v_cursor := student_info_pkg.get_students_by_section(1);

    -- Recorrer el cursor y mostrar los datos
    DBMS_OUTPUT.PUT_LINE('Students in Section:');
    LOOP
        FETCH v_cursor INTO v_id_student, v_surname, v_names;
        EXIT WHEN v_cursor%NOTFOUND;

        -- Mostrar datos del estudiante
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || v_id_student);
        DBMS_OUTPUT.PUT_LINE('Student Name: ' || v_surname || ' ' || v_names);
    END LOOP;

    -- Cerrar el cursor cuando hayas terminado
    CLOSE v_cursor;
END;

-- TRIGGERS


---
-- Crear un trigger para la tabla STUDENT
CREATE OR REPLACE TRIGGER STUDENT_CHECK_CONSTRAINTS
BEFORE INSERT OR UPDATE ON STUDENT
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_error_message VARCHAR2(200);
BEGIN
    -- Restricción CK_STUDENT_DOCUMENT_TYPE
    IF :NEW.document_type NOT IN ('DNI', 'CE') THEN
        v_error_message := 'El tipo de documento debe ser DNI o CE';
        RAISE_APPLICATION_ERROR(-20001, v_error_message);
    END IF;

    -- Restricción CK_STUDENT_DOCUMENT_TYPE_AND_DOCUMENT_NUMBER
    IF NOT (
        (:NEW.document_type = 'DNI' AND REGEXP_LIKE(:NEW.document_number, '^[0-9]{8}$'))
        OR
        (:NEW.document_type = 'CE' AND REGEXP_LIKE(:NEW.document_number, '^[0-9]{12}$'))
    ) THEN
        v_error_message := 'El formato del número de documento es incorrecto';
        RAISE_APPLICATION_ERROR(-20002, v_error_message);
    END IF;

    -- Restricción CHK_STUDENT_CELLPHONE_LENGTH
    IF LENGTH(:NEW.cell_phone) <> 9 OR SUBSTR(:NEW.cell_phone, 1, 1) <> '9' THEN
        v_error_message := 'La longitud del número de teléfono celular debe ser 9 y comenzar con 9';
        RAISE_APPLICATION_ERROR(-20003, v_error_message);
    END IF;

    -- Restricción CHK_STUDENT_EMAIL_FORMAT
    IF NOT REGEXP_LIKE(:NEW.email, '.+@.+\..+') THEN
        v_error_message := 'El formato del correo electrónico es incorrecto';
        RAISE_APPLICATION_ERROR(-20004, v_error_message);
    END IF;
    -- Restricción CK_STUDENT_STATES
    IF :NEW.states NOT IN ('A', 'I') THEN
        v_error_message := 'El estado debe ser A o I';
        RAISE_APPLICATION_ERROR(-20006, v_error_message);
    END IF;
END;

