# Laboratory Exercise 2, Assignment 2 
# IN HIGH LEVEL LANGUAGE 
# int a = 0xFEEDB987; 
# IN ASSEMBLY LANGUAGE 
.text 
lui s0, 0xFEEDC         
# s0 = 0xFEEDC000            
addi s0, s0, 0xFFFFF987 # s0 = 0xFEEDB987