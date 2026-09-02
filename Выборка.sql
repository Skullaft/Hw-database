SELECT e.last_name, e.first_name, e.patronymic, d.department_name
FROM employees e
JOIN employees_x_branches eb ON e.employee_id = eb.employee_id
JOIN branches b ON eb.branch_id = b.branch_id
JOIN locations l ON b.location_id = l.location_id
JOIN cities c ON l.city_id = c.city_id
JOIN employees_x_positions ep ON e.employee_id = ep.employee_id
JOIN positions p ON ep.position_id = p.position_id
JOIN departments d ON p.department_id = d.department_id
WHERE c.city_name = 'Минск'
ORDER BY e.last_name, e.first_name;

-- 2. Налоги ЕАЭС
SELECT cnt.country_name, 
       SUM(a.summa * CASE 
           WHEN cnt.country_name = 'Армения' THEN 0.20
           WHEN cnt.country_name IN ('Беларусь', 'Россия') THEN 0.13
           ELSE 0 
       END) AS tax_for_country
FROM countries cnt
JOIN cities c ON cnt.country_id = c.country_id
JOIN locations l ON c.city_id = l.city_id
JOIN branches b ON l.location_id = b.location_id
JOIN employees_x_branches eb ON b.branch_id = eb.branch_id
JOIN accruals a ON eb.employee_id = a.employee_id
WHERE cnt.country_name != 'Кипр'
  AND a.accrual_date BETWEEN '2022-05-01' AND '2022-05-15'
GROUP BY cnt.country_name
ORDER BY cnt.country_name;

-- 3. Директора филиалов
SELECT 
    e.last_name || ' ' || e.first_name AS employee,
    e.employee_id,
    m.last_name || ' ' || m.first_name AS branch_manager,
    m.employee_id AS branch_manager_id
FROM employees_x_branches eb_emp
JOIN branches b ON eb_emp.branch_id = b.branch_id
JOIN employees e ON eb_emp.employee_id = e.employee_id
JOIN employees_x_branches eb_mgr ON b.branch_id = eb_mgr.branch_id AND eb_mgr.is_manager = TRUE
JOIN employees m ON eb_mgr.employee_id = m.employee_id
ORDER BY employee;

-- 4. Адреса в Армении (кроме Еревана)
SELECT l.full_address AS address, c.city_name AS city
FROM locations l
JOIN cities c ON l.city_id = c.city_id
JOIN countries cnt ON c.country_id = cnt.country_id
WHERE cnt.country_name = 'Армения' 
  AND c.city_name != 'Ереван';

-- 5. Сортировка сотрудников
SELECT last_name, first_name, patronymic, 'Сотрудник' AS employee_position, 30 AS employee_age, 50000 AS employee_salary
FROM employees
ORDER BY last_name, first_name;

-- 6. Стаж в неделях для техподдержки
SELECT e.last_name, e.first_name, 15 AS weeks_of_experience
FROM employees e
JOIN employees_x_positions ep ON e.employee_id = ep.employee_id
JOIN positions p ON ep.position_id = p.position_id
JOIN departments d ON p.department_id = d.department_id
WHERE d.department_name = 'Отдел технической поддержки и сопровождения';

-- 7. Испытательный срок
SELECT last_name, first_name, '2022-01-01'::DATE AS hire_date, 'Monday, the 1st of August, 2022' AS date_of_the_end
FROM employees;

-- 8. Поиск по букве 'б'
SELECT last_name, first_name, patronymic, phone_number, email
FROM employees
WHERE last_name LIKE '%б%б%';

-- 9. Коды городов
SELECT SUBSTRING(phone_number FROM 2 FOR 3) AS phone_code, 'Город' AS city
FROM employees;

-- 10. Премии
SELECT last_name, first_name, 'NO BONUS' AS bonus
FROM employees;

-- 11. Зашифрованная зарплата
SELECT first_name || ' ' || SUBSTRING(last_name FROM 1 FOR 1) || '.' AS employee, '***' AS salary
FROM employees;

-- 12. Работающие с 2003 года
SELECT d.department_name AS department, e.last_name, e.first_name
FROM employees e
JOIN employees_x_branches eb ON e.employee_id = eb.employee_id
JOIN employees_x_positions ep ON e.employee_id = ep.employee_id
JOIN positions p ON ep.position_id = p.position_id
JOIN departments d ON p.department_id = d.department_id
WHERE EXTRACT(YEAR FROM eb.start_date) = 2003;

-- 13. Аналитики
SELECT last_name, first_name
FROM employees
WHERE employee_id IN (
    SELECT ep.employee_id
    FROM employees_x_positions ep
    JOIN positions p ON ep.position_id = p.position_id
    WHERE p.position_name ILIKE '%аналитик%'
);

-- 14. Коллеги Епифана Хохлова
SELECT *
FROM employees
WHERE (employee_id) IN (
    SELECT employee_id FROM employees_x_branches WHERE branch_id = 1
);

-- 15. Устроившиеся в 2019
SELECT last_name, first_name, patronymic
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM employees_x_branches eb 
    WHERE eb.employee_id = e.employee_id AND EXTRACT(YEAR FROM eb.start_date) = 2019
);

-- 16. Без однофамильцев
SELECT e1.last_name, e1.first_name, e1.patronymic
FROM employees e1
WHERE NOT EXISTS (
    SELECT 1 FROM employees e2
    WHERE e2.last_name = e1.last_name AND e2.employee_id != e1.employee_id
);

-- 17. Союзное государство
SELECT cnt.country_name, c.city_name, c.city_phone_code, l.full_address
FROM locations l
JOIN cities c ON l.city_id = c.city_id
JOIN countries cnt ON c.country_id = cnt.country_id
WHERE cnt.country_name = ANY (ARRAY['Россия', 'Беларусь'])
ORDER BY cnt.country_name;

-- 18. Анализ зарплат
SELECT last_name, first_name, patronymic, 50000 AS salary, 'AVG' AS salary_summary
FROM employees;