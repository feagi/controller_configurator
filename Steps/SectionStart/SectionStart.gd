extends BoxContainer
class_name SectionStart

const IMPORTERS_DIRECTORY: StringName = "res://Steps/Importers/"

signal attempt_import(import_UI: BaseConfigImporter, imported_data: PackedByteArray)
signal create_from_scratch()

var _import_methods_dropdown: OptionButton
var _import_file_button: Button

func _ready() -> void:
	_import_methods_dropdown = $ImportFrom/CenterContainer/VBoxContainer/HBoxContainer/OptionButton
	_import_file_button = $ImportFrom/CenterContainer/VBoxContainer/Button
	
	var import_options_folders: PackedStringArray = DirAccess.get_directories_at(IMPORTERS_DIRECTORY)
	var base_folder_index: int = import_options_folders.find("base")
	import_options_folders.remove_at(base_folder_index)
	
	for import_options_folder in import_options_folders:
		_import_methods_dropdown.add_item(import_options_folder)
	_import_methods_dropdown.selected = -1
	
func _option_from_dropdown_selected(index: int) -> void:
	var importer_scene_path: StringName = IMPORTERS_DIRECTORY + "/" + _import_methods_dropdown.get_item_text(index) + "/Importer.tscn"
	if not FileAccess.file_exists(importer_scene_path):
		_import_file_button.disabled = true
		_import_file_button.tooltip_text = "Unable to load UI elements for this option!"
		push_error("Unable to find scene 'Importer.tscn' from '%s'! Not allowing loading of the UI!" % importer_scene_path)
		return
	var importer_check = load(str(importer_scene_path)).instantiate()
	if importer_check is not BaseConfigImporter:
		_import_file_button.disabled = true
		_import_file_button.tooltip_text = "Unable to load UI elements for this option!"
		push_error("Unable to import scene at '%s' as a 'BaseConfigImporter'! Is the scene configured correctly?" % importer_scene_path)
		return
	_import_file_button.disabled = false
	_import_file_button.tooltip_text = "Load file to import..."
	

## Attempts to load the importer by name. If succeeds, emits attempt_import, otherwise logs an error
func _load_importer_UI() -> void:
	var importer_type_by_name: StringName = _import_methods_dropdown.get_item_text(_import_methods_dropdown.selected)
	var importer_scene_path: StringName = IMPORTERS_DIRECTORY + "/" + importer_type_by_name + "/Importer.tscn" # already checked this is valid	
	var importer: BaseConfigImporter = load(str(importer_scene_path)).instantiate()
	
	
func _create_scratch_pressed() -> void:
	create_from_scratch.emit()
