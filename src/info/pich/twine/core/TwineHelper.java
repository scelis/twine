package info.pich.twine.core;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;

import org.jruby.embed.LocalContextScope;
import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

public class TwineHelper {
	// set path to twine
	private static PathType twinePathType = PathType.CLASSPATH;
	private static File twineFile = new File("_twine_run.rb");

	/**
	 * 
	 * @param operation
	 * @param twineFile
	 * @param inOrOutFile
	 * @param extendedArgs
	 */
	public static void run(TwineOperation operation, File stringsFile,
			File inOrOutFile, String[] extendedArgs) {

		// assert basics
		if (operation == null) {
			throw new NullPointerException();
		}

		// get working dir from stringsFile
		String workingDir = stringsFile != null ? stringsFile.getParentFile()
				.getAbsolutePath() : null;

		// fill args array
		ArrayList<String> args = new ArrayList<String>();

		// add op
		String cmd = operation.toTwineArgument();
		if (cmd != null && cmd.length() > 0) {
			args.add(cmd);
		}

		// add string file - create if needed
		if (stringsFile != null) {
			if (!stringsFile.exists()) {
				try {
					stringsFile.createNewFile();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					System.err.println("Cant create new twine file");
				}
			}
			args.add(stringsFile.getName());
		}

		// add output file if twine wants it
		if (inOrOutFile != null && operation.getUsesInOrOutFile()) {
			args.add(inOrOutFile.getAbsolutePath());
		}

		// add the extended args
		if (extendedArgs != null) {
			for (String extendedArg : extendedArgs) {
				if (extendedArg.length() > 0)
					args.add(extendedArg);
			}
		}

		// execute JRuby
		String s = exec(workingDir, twinePathType, twineFile.getPath(),
				args.toArray(new String[0]));

		// write it to the file IF twine doesnt use the inOrOutFile
		if (s != null && inOrOutFile != null && !operation.getUsesInOrOutFile()) {
			try {
				if (!inOrOutFile.exists()) {
					inOrOutFile.createNewFile();
					PrintWriter out = new PrintWriter(
							inOrOutFile.getAbsolutePath());
					out.write(s);
					out.close();
				} else {
					System.err
							.println("Cant write twine result to disk, file already exists");
				}
			} catch (IOException e) {
				System.err.println("Cant write twine result to disk");
				e.printStackTrace();
			}
		}
	}

	/**
	 * @param args
	 * @return
	 */
	public static String run(String[] args) {
		return exec(null, twinePathType, twineFile.getPath(), args);
	}

	/**
	 * 
	 * @param workingDir
	 * @param pathType
	 * @param path
	 * @param args
	 * @return
	 */
	private static String exec(String workingDir, PathType pathType,
			String path, String[] args) {
		if (pathType == null || path == null)
			throw new NullPointerException();

		ScriptingContainer c = new ScriptingContainer(
				LocalContextScope.SINGLETHREAD);

		// apply environment
		if (workingDir != null && workingDir.length() > 0)
			c.setCurrentDirectory(workingDir);
		if (args != null && args.length > 0)
			c.setArgv(args);

		// redirect output (! if I do it before I apply the env the env is lost
		// :D)
		StringWriter sw = new StringWriter();
		c.setWriter(sw);

		// run it
		try {
			System.out.println(path + "@" + workingDir + " "
					+ Arrays.toString(args));
			c.runScriptlet(pathType, path);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// terminate the container
		c.terminate();

		// return stdout
		return sw.getBuffer().toString();
	}

}
