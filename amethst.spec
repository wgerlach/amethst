module AMETHSTService {
/* last parameter "tree" is optional
*/

funcdef amethst(string abundance_matrix, string groups_list, string commands_list, string tree) returns (string job_id);
funcdef status(string job_id) returns (string status)  ;
funcdef results(string job_id) returns (string results);
funcdef delete(string job_id) returns (string results);
};
