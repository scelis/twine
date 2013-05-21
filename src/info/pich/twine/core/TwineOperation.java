package info.pich.twine.core;

public enum TwineOperation {
	GENERATE_FILES, CONSUME_FILES, GENERATE_ZIPPED_PO, CONSUME_ZIPPED_PO, PRODUCE_REPORT, HELP;

	public String toTwineArgument() {
		switch (this) {
		case CONSUME_FILES:
			return "consume-all-string-files";
		case CONSUME_ZIPPED_PO:
			return "consume-loc-drop";
		case GENERATE_FILES:
			return "generate-all-string-files";
		case GENERATE_ZIPPED_PO:
			return "generate-loc-drop";
		case PRODUCE_REPORT:
			return "generate-report";
		default:
			return "";
		}
	}

	/**
	 * 
	 * @return
	 */
	public static String[] getDescriptions() {
		return new String[] {
				"Generate strings files for specific platforms and languages",
				"Consume platform specific strings files and generate new Twine String File",
				"Write a zipped PO File (interchange format)",
				"Read a zipped PO File (interchange format)",
				"Produce a report" };
	}

	/**
	 * 
	 * @param i
	 *            1 based
	 * @return
	 */
	public static TwineOperation fromInt(int i) {
		switch (i) {
		case 1:
			return GENERATE_FILES;
		case 2:
			return CONSUME_FILES;
		case 3:
			return GENERATE_ZIPPED_PO;
		case 4:
			return CONSUME_ZIPPED_PO;
		case 5:
			return PRODUCE_REPORT;
		default:
			return null;
		}
	}

	public String getDefaultExtendedArgs() {
		switch (this) {
		case CONSUME_FILES:
			return "--developer-language en --consume-all --consume-comments";
		case CONSUME_ZIPPED_PO:
			return "--format gettext";
		case GENERATE_ZIPPED_PO:
			return "--format gettext";
		default:
			return "";
		}
	}

	public boolean getUsesInOrOutFile() {
		return this != PRODUCE_REPORT;
	}
}
