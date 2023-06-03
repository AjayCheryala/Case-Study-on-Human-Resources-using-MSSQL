-- Create 'departments' table
CREATE TABLE departments (
    id int IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    manager_id INT
);

-- Create 'employees' table
CREATE TABLE employees (
    id int IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

-- Create 'projects' table
CREATE TABLE projects (
    id int IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);

-- Insert data into 'departments'
INSERT INTO departments (name, manager_id)
VALUES ('HR', 1), ('IT', 2), ('Sales', 3);

-- Insert data into 'employees'
INSERT INTO employees (name, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

-- Insert data into 'projects'
INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
       
       UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
WHERE name = 'HR';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
WHERE name = 'IT';

UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson')
WHERE name = 'Sales';



select * from departments;

select * from employees;

select * from projects;

-- SQL Challenge Questions

--1. Find the longest ongoing project for each department.

select d.name department_name, 
	   p.name project_name,  
	   DATEDIFF(day, p.start_date, p.end_date) as days 
from departments d
left join projects p
on d.id = p.department_id
order by 3 desc;


--2. Find all employees who are not managers.

select * from employees
where job_title not like '%manager%';



--3. Find all employees who have been hired 
--after the start of a project in their department.

select e.id
, e.name
, d.name dept_name
, p.name project_name
, e.hire_date emp_hired
, p.start_date proj_start
from employees e 
left join projects p
on e.department_id = p.department_id
join departments d
on p.department_id = d.id
where e.hire_date  > p.start_date

--4. Rank employees within each department based on 
--their hire date (earliest hire gets the highest rank).

select e.id, e.name, e.hire_date, d.name,
RANK() over(partition by d.name order by e.hire_date) rnk
from employees e
left join departments d
on e.department_id = d.id

--5. Find the duration between the hire date of each employee and 
--the hire date of the next employee hired in the same department.

with cte as (
select name, hire_date, department_id,
lead(name,1) over(partition by department_id order by hire_date) new_joinee,
lead(hire_date,1) over(partition by department_id order by hire_date) new_hiredate,
DATEDIFF(DAY, hire_date
			, lead(hire_date,1) over(partition by department_id order by hire_date)) days
from employees)

select d.name dept_name, c.name emp_name
, c.hire_date, c.new_joinee
, c.new_hiredate, c.days days_to_nexthire
 from cte c
 left join departments d
 on c.department_id = d.id
 where days is not null

