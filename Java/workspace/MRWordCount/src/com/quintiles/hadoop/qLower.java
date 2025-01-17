package com.quintiles.hadoop;

import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.hive.ql.udf.UDFType;
import org.apache.hadoop.io.Text;

@UDFType(deterministic = true) 
@Description(name = "qLower", 
value = "qLower(expr1) returns expr1 in Lowercase",
extended = "Example:\n"+ " SELECT qLower(name) from employees a;\n" + " udhay"
)  

public final class qLower extends UDF {

  public Text evaluate(final Text s) {

    if (s == null) { return null; }

    return new Text(s.toString().toLowerCase());

  }
}
