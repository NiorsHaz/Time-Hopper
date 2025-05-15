extends Node
class_name StateDialogue

var quiz_qcm_luna_score: int = 0
var quiz_qcm_luna_use_IA: bool = false

var quiz_yn_luna_score: int = 0
var quiz_yn_luna_use_IA: bool = false

var quiz_vf_luna_score: int = 0
var quiz_vf_luna_use_IA: bool = false

var return_number: int


var bad_review : int
var medium_review : int
var great_review : int


func save_review():
	var review : Review = DataManager.load("gameReview")
	review.bad_review = bad_review
	review.medium_review = medium_review
	review.great_review = great_review
	DataManager.save(review, "gameReview")
	
func reset():
	return_number += 0
	quiz_qcm_luna_score = 0
	quiz_qcm_luna_use_IA = false

	quiz_yn_luna_score = 0
	quiz_yn_luna_use_IA = false

	quiz_vf_luna_score = 0
	quiz_vf_luna_use_IA = false
