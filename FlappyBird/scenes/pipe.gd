class_name Pipe

extends Area2D

signal scored

func _on_score_area_body_entered(body):
	scored.emit()
