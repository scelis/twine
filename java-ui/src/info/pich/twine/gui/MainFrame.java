package info.pich.twine.gui;

import info.pich.twine.core.TwineHelper;
import info.pich.twine.core.TwineOperation;

import java.awt.EventQueue;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.io.File;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.border.EmptyBorder;

@SuppressWarnings("serial")
public class MainFrame extends JFrame {

	private JPanel contentPane;
	private JPanel overviewPane;
	private JTextField textFieldTwineStringsFilename;
	private JLabel lblOperation;
	private JComboBox comboBoxOperation;
	private JPanel operationPane;
	private JButton btnBrowseButton;

	private final Action actionBrowseForTwineFile = new BrowseSwingAction(true,
			false, false, false);
	private final Action actionSelectOperationMode = new OperationSwingAction();
	private final Action actionBrowseForInputOrOutput = new BrowseSwingAction(
			false, false, false, false);
	private final Action actionExecute = new ExecuteSwingAction();

	private JLabel lblOutputOrInput;
	private JTextField textFieldInputOrOutput;
	private JButton btnBrowseForOutput;
	private JButton btnAct;
	private JTextField textFieldExtendedArgs;
	private JLabel lblExtendedArgumentsdefaults;

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					MainFrame frame = new MainFrame();
					frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the frame.
	 */
	public MainFrame() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 548, 358);

		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(new GridBagLayout());

		overviewPane = new JPanel();
		overviewPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		GridBagConstraints gbc_overviewPane = new GridBagConstraints();
		gbc_overviewPane.fill = GridBagConstraints.BOTH;
		gbc_overviewPane.anchor = GridBagConstraints.NORTH;
		gbc_overviewPane.gridy = 0;
		gbc_overviewPane.gridx = 0;
		contentPane.add(overviewPane, gbc_overviewPane);
		GridBagLayout gbl_overviewPane = new GridBagLayout();
		gbl_overviewPane.columnWidths = new int[] { 484, 0 };
		gbl_overviewPane.rowHeights = new int[] { 15, 45, 35, 35, 0, 45 };
		gbl_overviewPane.columnWeights = new double[] { 1.0, Double.MIN_VALUE };
		gbl_overviewPane.rowWeights = new double[] { 0.0, 0.0, 0.0,
				Double.MIN_VALUE, 0.0, 0.0 };
		overviewPane.setLayout(gbl_overviewPane);

		JLabel lblTwineStringsFilename = new JLabel("Twine Strings Filename");
		GridBagConstraints c = new GridBagConstraints();
		c.insets = new Insets(0, 0, 5, 0);
		c.gridx = 0;
		c.gridy = 0;
		c.anchor = GridBagConstraints.LAST_LINE_START;
		c.gridwidth = 2;
		overviewPane.add(lblTwineStringsFilename, c);

		textFieldTwineStringsFilename = new JTextField();
		GridBagConstraints c2 = new GridBagConstraints();
		c2.insets = new Insets(0, 3, 5, 5);
		c2.weighty = 1.0;
		c2.fill = GridBagConstraints.HORIZONTAL;
		c2.gridx = 0;
		c2.gridy = 1;
		c2.weightx = 1;
		overviewPane.add(textFieldTwineStringsFilename, c2);
		textFieldTwineStringsFilename.setColumns(10);

		btnBrowseButton = new JButton("Browse ...");
		btnBrowseButton.setAction(actionBrowseForTwineFile);
		GridBagConstraints gbc_btnBrowseButton = new GridBagConstraints();
		gbc_btnBrowseButton.insets = new Insets(0, 0, 5, 0);
		gbc_btnBrowseButton.weighty = 1.0;
		gbc_btnBrowseButton.gridx = 1;
		gbc_btnBrowseButton.gridy = 1;
		overviewPane.add(btnBrowseButton, gbc_btnBrowseButton);

		lblOperation = new JLabel("What do you want to do?");
		lblOperation.setVerticalAlignment(SwingConstants.BOTTOM);
		lblOperation.setHorizontalAlignment(SwingConstants.CENTER);
		GridBagConstraints gbc_lblOperation = new GridBagConstraints();
		gbc_lblOperation.anchor = GridBagConstraints.LAST_LINE_START;
		gbc_lblOperation.fill = GridBagConstraints.VERTICAL;
		gbc_lblOperation.insets = new Insets(0, 0, 5, 5);
		gbc_lblOperation.gridx = 0;
		gbc_lblOperation.gridy = 2;
		overviewPane.add(lblOperation, gbc_lblOperation);

		comboBoxOperation = new JComboBox();
		comboBoxOperation
				.setModel(new DefaultComboBoxModel(
						new String[] {
								"",
								"Generate strings files for specific platforms and languages",
								"Consume platform specific strings files and generate new Twine String File",
								"Write a zipped PO File (interchange format)",
								"Read a zipped PO File (interchange format)",
								"Produce a report" }));
		comboBoxOperation.setSelectedIndex(0);
		GridBagConstraints gbc_comboBoxOperation = new GridBagConstraints();
		gbc_comboBoxOperation.anchor = GridBagConstraints.NORTH;
		gbc_comboBoxOperation.insets = new Insets(0, 0, 5, 0);
		gbc_comboBoxOperation.weighty = 1.0;
		gbc_comboBoxOperation.gridwidth = 2;
		gbc_comboBoxOperation.fill = GridBagConstraints.BOTH;
		gbc_comboBoxOperation.gridx = 0;
		gbc_comboBoxOperation.gridy = 3;
		comboBoxOperation.setAction(actionSelectOperationMode);
		overviewPane.add(comboBoxOperation, gbc_comboBoxOperation);

		lblExtendedArgumentsdefaults = new JLabel(
				"Extended Arguments (defaults proposed)");
		lblExtendedArgumentsdefaults
				.setVerticalAlignment(SwingConstants.BOTTOM);
		lblExtendedArgumentsdefaults
				.setHorizontalAlignment(SwingConstants.LEFT);
		GridBagConstraints gbc_lblExtendedArgumentsdefaults = new GridBagConstraints();
		gbc_lblExtendedArgumentsdefaults.fill = GridBagConstraints.VERTICAL;
		gbc_lblExtendedArgumentsdefaults.anchor = GridBagConstraints.LAST_LINE_START;
		gbc_lblExtendedArgumentsdefaults.insets = new Insets(0, 0, 5, 5);
		gbc_lblExtendedArgumentsdefaults.gridx = 0;
		gbc_lblExtendedArgumentsdefaults.gridy = 4;
		overviewPane.add(lblExtendedArgumentsdefaults,
				gbc_lblExtendedArgumentsdefaults);

		textFieldExtendedArgs = new JTextField();
		GridBagConstraints gbc_textField = new GridBagConstraints();
		gbc_textField.anchor = GridBagConstraints.NORTH;
		gbc_textField.weighty = 1.0;
		gbc_textField.gridwidth = 2;
		gbc_textField.insets = new Insets(0, 3, 0, 5);
		gbc_textField.fill = GridBagConstraints.HORIZONTAL;
		gbc_textField.gridx = 0;
		gbc_textField.gridy = 5;
		overviewPane.add(textFieldExtendedArgs, gbc_textField);
		textFieldExtendedArgs.setColumns(10);

		operationPane = new JPanel();
		GridBagConstraints c4 = new GridBagConstraints();
		c4.anchor = GridBagConstraints.SOUTH;
		c4.weighty = 1.0;
		c4.weightx = 1.0;
		c4.gridx = 0;
		c4.gridy = 1;
		c4.fill = GridBagConstraints.BOTH;
		contentPane.add(operationPane, c4);
		operationPane.setLayout(new GridBagLayout());

		lblOutputOrInput = new JLabel("Output or Input");
		GridBagConstraints gbc_lblOutputOrInput = new GridBagConstraints();
		gbc_lblOutputOrInput.fill = GridBagConstraints.BOTH;
		gbc_lblOutputOrInput.anchor = GridBagConstraints.LINE_START;
		gbc_lblOutputOrInput.insets = new Insets(5, 5, 5, 5);
		gbc_lblOutputOrInput.gridx = 0;
		gbc_lblOutputOrInput.gridy = 0;
		operationPane.add(lblOutputOrInput, gbc_lblOutputOrInput);

		textFieldInputOrOutput = new JTextField();
		textFieldInputOrOutput.setColumns(10);
		GridBagConstraints gbc_textFieldInputOrOutput = new GridBagConstraints();
		gbc_textFieldInputOrOutput.weightx = 1.0;
		gbc_textFieldInputOrOutput.fill = GridBagConstraints.HORIZONTAL;
		gbc_textFieldInputOrOutput.insets = new Insets(0, 0, 0, 5);
		gbc_textFieldInputOrOutput.gridx = 0;
		gbc_textFieldInputOrOutput.gridy = 1;
		operationPane.add(textFieldInputOrOutput, gbc_textFieldInputOrOutput);

		btnBrowseForOutput = new JButton("Browse ...");
		GridBagConstraints gbc_button = new GridBagConstraints();
		gbc_button.gridx = 1;
		gbc_button.gridy = 1;
		btnBrowseForOutput.setAction(actionBrowseForInputOrOutput);
		operationPane.add(btnBrowseForOutput, gbc_button);

		btnAct = new JButton("Execute");
		GridBagConstraints gbc_act = new GridBagConstraints();
		gbc_act.gridwidth = 2;
		gbc_act.gridx = 0;
		gbc_act.gridy = 2;
		btnAct.setAction(actionExecute);
		operationPane.add(btnAct, gbc_act);
		btnAct.setEnabled(false);

		//fillTest();
		// executeTwine();
	}

//	private void fillTest() {
//		textFieldTwineStringsFilename
//				.setText("/Users/dpich/Desktop/TWINE/sampledata/strings");
//		comboBoxOperation.setSelectedIndex(1);
//		textFieldInputOrOutput
//				.setText("/Users/dpich/Desktop/TWINE/sampledata/generate-");
//	}

	private class BrowseSwingAction extends AbstractAction {
		boolean _forTwine;
		boolean _filesOnly;
		boolean _foldersOnly;
		boolean _outputInsteadOfInput;

		public BrowseSwingAction(boolean forTwine, boolean filesOnly,
				boolean foldersOnly, boolean outputInsteadOfInput) {
			putValue(NAME, "Browse...");

			if (!forTwine) {
				if (outputInsteadOfInput)
					putValue(SHORT_DESCRIPTION, "Select a output "
							+ (filesOnly ? "file" : (foldersOnly ? "folder"
									: "file or folder")));
				else
					putValue(SHORT_DESCRIPTION, "Select an input "
							+ (filesOnly ? "file" : (foldersOnly ? "folder"
									: "file or folder")));
			} else {
				putValue(SHORT_DESCRIPTION, "Select a twine strings file");
			}

			_forTwine = forTwine;
			_filesOnly = filesOnly;
			_foldersOnly = foldersOnly;
			_outputInsteadOfInput = outputInsteadOfInput;
		}

		public void actionPerformed(ActionEvent e) {
			showPicker(_forTwine, _filesOnly, _foldersOnly,
					_outputInsteadOfInput);
		}
	}

	private class OperationSwingAction extends AbstractAction {
		public OperationSwingAction() {
			putValue(NAME, "Select an operation");
			putValue(SHORT_DESCRIPTION, "Select an operation from the combobox");
		}

		public void actionPerformed(ActionEvent e) {
			reflectOperationMode();

		}
	}

	private class ExecuteSwingAction extends AbstractAction {
		public ExecuteSwingAction() {
			putValue(NAME, "Execute selected an operation");
			putValue(SHORT_DESCRIPTION,
					"Executes the operation selected in the combobox");
		}

		public void actionPerformed(ActionEvent e) {
			executeTwine();
		}
	}

	// ---

	private void reflectOperationMode() {
		Action a = null;

		TwineOperation op = TwineOperation.fromInt(comboBoxOperation
				.getSelectedIndex());
		if (op != null) {
			switch (op) {
			case GENERATE_FILES:
				a = new BrowseSwingAction(false, false, true, true);
				break;
			case CONSUME_FILES:
				a = new BrowseSwingAction(false, false, false, false);
				break;
			case GENERATE_ZIPPED_PO:
				a = new BrowseSwingAction(false, true, false, true);
				break;
			case CONSUME_ZIPPED_PO:
				a = new BrowseSwingAction(false, true, false, false);
				break;
			case PRODUCE_REPORT:
				a = new BrowseSwingAction(false, true, false, true);
				break;
			default:
				a = null;
				break;
			}
		}

		btnAct.setEnabled(a != null);
		btnBrowseForOutput.setAction(a);
		lblOutputOrInput.setText(a != null ? String.valueOf(a
				.getValue(Action.SHORT_DESCRIPTION)) : "");
		textFieldExtendedArgs.setText(op != null ? op.getDefaultExtendedArgs()
				: "");
	}

	private void showPicker(final boolean forTwine, boolean filesOnly,
			boolean foldersOnly, boolean outputInsteadOfInput) {
		filesOnly = forTwine;

		String desc = String.valueOf((forTwine ? btnBrowseButton
				: btnBrowseForOutput).getAction().getValue(
				Action.SHORT_DESCRIPTION));

		JFileChooser chooser = new JFileChooser(desc);
		chooser.setDialogType(outputInsteadOfInput ? JFileChooser.SAVE_DIALOG
				: JFileChooser.OPEN_DIALOG);
		chooser.setFileSelectionMode(filesOnly ? JFileChooser.FILES_ONLY
				: (foldersOnly ? JFileChooser.DIRECTORIES_ONLY
						: JFileChooser.FILES_AND_DIRECTORIES));

		File file = new File("~");
		chooser.setCurrentDirectory(file);

		chooser.setVisible(true);
		final int result;
		if (forTwine)
			result = chooser.showSaveDialog(null);
		else
			result = chooser.showOpenDialog(null);

		if (result == JFileChooser.APPROVE_OPTION) {
			File inputVerzFile = chooser.getSelectedFile();
			String inputVerzStr = inputVerzFile.getAbsolutePath();
			System.out.println("Eingabepfad:" + inputVerzStr);

			if (forTwine)
				textFieldTwineStringsFilename.setText(inputVerzStr);
			else
				textFieldInputOrOutput.setText(inputVerzStr);
		}
	}

	private void executeTwine() {
		TwineOperation twineOperation = TwineOperation
				.fromInt(comboBoxOperation.getSelectedIndex());
		File twineStringFile = new File(textFieldTwineStringsFilename.getText());
		File inOrOutFile = new File(textFieldInputOrOutput.getText());
		String[] extendedArgs = textFieldExtendedArgs.getText().split(" ");

		TwineHelper.run(twineOperation, twineStringFile, inOrOutFile,
				extendedArgs);
	}
}
