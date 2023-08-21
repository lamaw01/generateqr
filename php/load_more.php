<?php
require '../db_connect.php';
header('Content-Type: application/json; charset=utf-8');

// make input json
$inputJSON = file_get_contents('php://input');
$input = json_decode($inputJSON, TRUE);

// if not put id die
if($_SERVER['REQUEST_METHOD'] == 'POST' && array_key_exists('id', $input)){
    $id = $input['id'];
    $department_id = $input['department_id'];
    
    // if id = 000 search all
    if($department_id == '000'){
        $sql_get_employee_department = "SELECT tbl_employee.id, tbl_employee.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name FROM tbl_employee 
        LEFT JOIN tbl_employee_department ON tbl_employee.employee_id = tbl_employee_department.employee_id 
        WHERE tbl_employee.id > :id AND tbl_employee.active = 1 
        GROUP BY tbl_employee.employee_id ORDER BY tbl_employee.last_name LIMIT 100;";

        try {
            $set=$conn->prepare("SET SQL_MODE=''");
            $set->execute();

            $get_employee_department= $conn->prepare($sql_get_employee_department);
            $get_employee_department->bindParam(':id', $id, PDO::PARAM_STR);
            $get_employee_department->execute();
            $result_get_employee_department = $get_employee_department->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($result_get_employee_department);
        } catch (PDOException $e) {
            echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
        } finally{
            // Closing the connection.
            $conn = null;
        }
    }else{
        $sql_get_employee_department = "SELECT tbl_employee.id, tbl_employee.employee_id, tbl_employee.first_name, tbl_employee.last_name, tbl_employee.middle_name FROM tbl_employee 
        LEFT JOIN tbl_employee_department ON tbl_employee.employee_id = tbl_employee_department.employee_id 
        WHERE tbl_employee.id > :id AND tbl_employee_department.department_id = :department_id AND tbl_employee.active = 1
        GROUP BY tbl_employee.employee_id ORDER BY tbl_employee.last_name LIMIT 100;";
    
        try {
            $set=$conn->prepare("SET SQL_MODE=''");
            $set->execute();

            $get_employee_department= $conn->prepare($sql_get_employee_department);
            $get_employee_department->bindParam(':id', $id, PDO::PARAM_STR);
            $get_employee_department->bindParam(':department_id', $department_id, PDO::PARAM_STR);
            $get_employee_department->execute();
            $result_get_employee_department = $get_employee_department->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($result_get_employee_department);
        } catch (PDOException $e) {
            echo json_encode(array('success'=>false,'message'=>$e->getMessage()));
        } finally{
            // Closing the connection.
            $conn = null;
        }
    }
}
else{
    echo json_encode(array('success'=>false,'message'=>'Error input'));
    die();
}
?>