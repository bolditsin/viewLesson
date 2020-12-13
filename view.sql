# 1. Создать VIEW на основе запросов, которые вы сделали в ДЗ к уроку 3.

CREATE VIEW CityDate AS
	SELECT 
		_cities.title AS city, 
        _regions.title AS region, 
        _countries.title AS country  
			FROM _cities 
	LEFT JOIN 
    _regions ON region_id = _regions.id 
	LEFT JOIN 
    _countries ON _cities.country_id = _countries.id;

#получаем все данные о городе, используя VIEW
SELECT * FROM CityDate;

# Получаем все города из Московской области, используя VIEW
SELECT city FROM CityDate WHERE region = 'Московская область';

# создаем вид по отделам.
CREATE VIEW DepartmentsSalary AS
	SELECT 
		AVG(salaries.salary) AS salary,
        departments.dept_name AS department 
			FROM departments
	LEFT JOIN 
		dept_emp ON departments.dept_no = dept_emp.dept_no 
	LEFT JOIN 
		salaries ON dept_emp.emp_no = salaries.emp_no 
	WHERE
		salaries.to_date > now()
	GROUP BY 
		departments.dept_no;

# получаем среднюю зарплату по отделам.
SELECT * FROM DepartmentsSalary;

# создаем вид EmloyeerMaxSalary
CREATE VIEW EmloyeerMaxSalary AS
	SELECT 
		max(salary) AS max_salary, 
		concat(first_name, ' ', last_name) as employee, 
        employees.emp_no AS emp_number FROM salaries 
	JOIN 
		employees ON salaries.emp_no = employees.emp_no WHERE salaries.to_date > now()
	GROUP BY employees.emp_no 
    ORDER BY max_salary DESC;

#  Выбрать максимальную зарплату у сотрудника.
SELECT employee, max_salary FROM EmloyeerMaxSalary;

# Удалить одного сотрудника, у которого максимальная зарплата.
DELETE FROM employees WHERE emp_no = (SELECT emp_number FROM EmloyeerMaxSalary HAVING max(max_salary));

# создаем вид DepartmentsDate
CREATE VIEW DepartmentsDate AS
	SELECT
		count(dept_emp.emp_no) AS emp_count, 
        departments.dept_name AS department, 
        sum(salaries.salary) AS money FROM dept_emp
	LEFT JOIN 
		departments ON dept_emp.dept_no = departments.dept_no
	LEFT JOIN 
		salaries ON salaries.emp_no = dept_emp.emp_no 
	WHERE 
		dept_emp.to_date > now() AND salaries.to_date > now()
	GROUP BY dept_emp.dept_no; 

# Посчитать количество сотрудников во всех отделах.
SELECT department, emp_count FROM DepartmentsDate;

# Найти количество сотрудников в отделах и посмотреть сколько всего денег получает отдел.
SELECT department, emp_count, money FROM DepartmentsDate;

# 2. Создать функцию, которая найдет менеджера по имени и фамилии.
delimiter //
CREATE FUNCTION findmanager(firstName CHAR(14), lastName CHAR(16))
RETURNS  VARCHAR(14) 
BEGIN

RETURN ( SELECT dept_manager.emp_no
FROM
    dept_manager
        JOIN
    employees ON dept_manager.emp_no = employees.emp_no
        JOIN
    departments ON dept_manager.dept_no = departments.dept_no
WHERE
    first_name = firstName
        AND last_name = lastName);

END//
delimiter ;

SELECT findmanager('Ivanov', 'Petrov');

# 3. Создать триггер, который при добавлении нового сотрудника будет выплачивать ему вступительный бонус в таблицу salary.
ALTER TABLE employees CHANGE emp_no emp_no INT(11) AUTO_INCREMENT;

delimiter //

CREATE PROCEDURE insert_bonus(emp int(11), bonus int(11))
BEGIN
	INSERT INTO salaries (emp_no, salary, from_date, to_date)
    VALUES (emp, bonus, now(), adddate(now(), INTERVAL 1 YEAR));
END //

delimiter ;

CREATE TRIGGER addbonus AFTER INSERT ON employees
FOR EACH ROW CALL insert_bonus(NEW.emp_no, 10000);

INSERT INTO 
	employees (birth_date, first_name, last_name, gender, hire_date) 
    VALUES 
		('1992-10-10', 'FEDOR', 'SIDOROV', 'M', '2020-01-20');

SELECT * FROM salaries ORDER BY from_date DESC;
'\n'