"use client";
import React from "react";
import ComputeForm from "./compute";
import LogForm from "./log";
import StatusForm from "./status";
import AddForm from "./add";
import UpdateForm from "./update";


const AllForm = () => {
  return (
  <>
    <ComputeForm/>
    <AddForm/>
    <LogForm/>
    <StatusForm/>
    <UpdateForm/>
  </>
  );
};

export default AllForm;
