extends BoxContainer
class_name SectionStart

const IMPORTERS_DIRECTORY: StringName = "res://Steps/Importers/CustomImporters/"

signal attempt_import(import_UI: BaseConfigImporter, imported_data: PackedByteArray, file_name: StringName)
signal create_from_scratch()

var _import_methods_dropdown: OptionButton
var _import_file_button: Button
var _import_text_button: Button
var _text_import: TextEdit

func _ready() -> void:
	_import_methods_dropdown = $ImportFrom/CenterContainer/VBoxContainer/HBoxContainer/OptionButton
	_import_file_button = $ImportFrom/CenterContainer/VBoxContainer/HBoxContainer2/FIle
	_import_text_button = $ImportFrom/CenterContainer/VBoxContainer/HBoxContainer2/Text
	_text_import = $ImportFrom/CenterContainer/VBoxContainer/TextImport
	
	var import_options_folders: PackedStringArray = DirAccess.get_directories_at(IMPORTERS_DIRECTORY)
	
	for import_options_folder in import_options_folders:
		_import_methods_dropdown.add_item(import_options_folder)
	_import_methods_dropdown.selected = -1
	_text_import.text = ""
	_text_import.editable = false
	
	
	#TODO remove this segment once feature is implemented!
	if OS.get_name() == "Web":
		_import_file_button.disabled = true
		_import_file_button.tooltip_text = "File import for web exports not yet available!"


func reset_UI() -> void:
	_import_methods_dropdown.selected = -1


func _option_from_dropdown_selected(index: int) -> void:
	var importer_scene_path: StringName = IMPORTERS_DIRECTORY + "/" + _import_methods_dropdown.get_item_text(index) + "/Importer.tscn"
	if not ResourceLoader.exists(importer_scene_path):
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

func _open_config_from_file_pressed() -> void:
	var importer: BaseConfigImporter = _try_to_get_importer_from_dropdown_selection()
	if !importer:
		push_error("Unable to load config importer UI!")
		return
	
	if OS.get_name() != "Web":
		# use this method to get file
		var file_selector: FileDialog = FileDialog.new()
		file_selector.use_native_dialog = true
		file_selector.add_filter("*." + importer.get_expected_file_extension())
		file_selector.title = "Select your file to import"
		file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_selector.show()
		var path: StringName = await file_selector.file_selected
		
		var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
		if len(bytes) == 0:
			push_error("Unable to open the file at path '%s'!" % path)
			return

		path = path.split("/")[-1] # get filename
		attempt_import.emit(_try_to_get_importer_from_dropdown_selection(), bytes, path)
		return

	# TODO HTML5 JS interactions
	push_error("HTML5 File import not yet Implemented!")

func _open_config_from_text_pressed() -> void:
	if !_text_import.visible:
		_text_import.visible = true
		return
	
	if _text_import.text.is_empty():
		# Don't both trying to import an empty text
		return
	
	var importer: BaseConfigImporter = _try_to_get_importer_from_dropdown_selection()
	if !importer:
		push_error("Unable to load config importer UI!")
		return
	
	var bytes: PackedByteArray = _text_import.text.to_utf8_buffer()
	if len(bytes) == 0:
		push_error("Unable to parse given string! '%s'!")
		return

	attempt_import.emit(_try_to_get_importer_from_dropdown_selection(), bytes, "String")
	return




func _create_scratch_pressed() -> void:
	create_from_scratch.emit()

## Attempts to return the importer UI object as per the drop down. Returns null if something is wrong
func _try_to_get_importer_from_dropdown_selection() -> BaseConfigImporter:
	if _import_methods_dropdown.selected == -1:
		return null
	var importer_type_by_name: StringName = _import_methods_dropdown.get_item_text(_import_methods_dropdown.selected)
	var importer_scene_path: StringName = IMPORTERS_DIRECTORY + "/" + importer_type_by_name + "/Importer.tscn"
	if not ResourceLoader.exists(importer_scene_path):
		return null
	var importer_check = load(str(importer_scene_path)).instantiate()
	if importer_check is not BaseConfigImporter:
		return null
	return importer_check as BaseConfigImporter
