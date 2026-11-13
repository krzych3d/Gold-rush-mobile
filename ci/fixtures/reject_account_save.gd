extends "res://scripts/account_progress.gd"
## Exercise rollback without manufacturing an OS I/O error in CI logs.
func _save() -> bool:
	return false
