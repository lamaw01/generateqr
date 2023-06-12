<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// if not put id die
if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('employee_id', $input)){
    $department_id = $input['department_id'];
    $employee_id = $input['employee_id'];

    $concat_employee_id = "%$employee_id%";

    $sql_search_employee= "SELECT tbl_employee.id,tbl_employee.employee_id,tbl_employee.name FROM tbl_employee 
    LEFT JOIN tbl_employee_department ON tbl_employee.employee_id = tbl_employee_department.employee_id 
    WHERE tbl_employee_department.department_id = :department_id 
    AND (tbl_employee.employee_id LIKE :employee_id OR tbl_employee.name LIKE :employee_id)  
    AND tbl_employee.active = 1 ORDER BY tbl_employee.employee_id;";

    try {
        $get_search_employee= $conn->prepare($sql_search_employee);
        $get_search_employee->bindParam(':department_id', $department_id, PDO::PARAM_STR);
        $get_search_employee->bindParam(':employee_id', $concat_employee_id, PDO::PARAM_STR);
        $get_search_employee->execute();
        $result_get_search_employee = $get_search_employee->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($result_get_search_employee);
    } catch (PDOException $e) {
        echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
    } finally{
        // Closing the connection.
        $conn = null;
    }
}
else{
    echo json_encode(array('success'=>false,'message'=>'Error input'));
    die();
}
?>