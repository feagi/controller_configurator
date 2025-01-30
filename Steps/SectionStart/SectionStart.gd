extends BoxContainer
class_name SectionStart

const IMPORTERS_DIRECTORY: StringName = "res://Steps/Importers/CustomImporters/"

signal attempt_import(import_UI: BaseConfigImporter, imported_data: PackedByteArray, file_name: StringName)
signal create_from_scratch()

var _import_methods_dropdown: OptionButton
var _import_file_button: Button

func _ready() -> void:
	_import_methods_dropdown = $ImportFrom/CenterContainer/VBoxContainer/HBoxContainer/OptionButton
	_import_file_button = $ImportFrom/CenterContainer/VBoxContainer/Button
	
	var import_options_folders: PackedStringArray = DirAccess.get_directories_at(IMPORTERS_DIRECTORY)
	
	for import_options_folder in import_options_folders:
		_import_methods_dropdown.add_item(import_options_folder)
	_import_methods_dropdown.selected = -1


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
	

## Attempts to load the importer by name. If succeeds, emits attempt_import, otherwise logs an error
func _load_importer_UI() -> void:
	var importer: BaseConfigImporter = _try_to_get_importer_from_dropdown_selection()
	if !importer:
		push_error("Unable to load config importer UI!")
		return
	
	if OS.get_name() != "HTML5":
		# use this method to get file
		var file_selector: FileDialog = FileDialog.new()
		file_selector.use_native_dialog = true
		file_selector.add_filter("*." + importer.get_expected_file_extension())
		file_selector.title = "Select your file to import"
		file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_selector.file_selected.connect(_non_HTML_filebrowser_picked)
		file_selector.show()
	# TODO HTML5 JS interactions


func _create_scratch_pressed() -> void:
	create_from_scratch.emit()

func _non_HTML_filebrowser_picked(path: StringName) -> void:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if len(bytes) == 0:
		push_error("Unable to open the file at path '%s'!" % path)
		return
	
	path = path.split("/")[-1] # get filename
	attempt_import.emit(_try_to_get_importer_from_dropdown_selection(), bytes, path)

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
