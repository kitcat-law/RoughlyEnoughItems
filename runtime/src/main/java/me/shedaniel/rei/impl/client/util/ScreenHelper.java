package me.shedaniel.rei.impl.client.util;


import com.mojang.blaze3d.platform.InputConstants;
import com.mojang.blaze3d.platform.Window;
import net.minecraft.client.Minecraft;
import net.minecraft.client.input.InputQuirks;
import org.lwjgl.glfw.GLFW;

public final class ScreenHelper {
	
	private ScreenHelper() {} // utility

    // --- Window + key state ---------------------------------------------------

    private static Window win() {
        // IMPORTANT: Window is com.mojang.blaze3d.platform.Window
        return Minecraft.getInstance().getWindow();
    }

    private static boolean key(int glfwKey) {
        // Modern MC has an overload that accepts Window directly.
        // If your mappings require a long handle, swap to:
        //   return InputConstants.isKeyDown(win().getWindow(), glfwKey);
        return InputConstants.isKeyDown(win(), glfwKey);
    }

    // --- Modifier keys (replacement for Screen.has*Down) ----------------------

    public static boolean hasControlDown() {
        return key(InputQuirks.EDIT_SHORTCUT_KEY_LEFT) || key(InputQuirks.EDIT_SHORTCUT_KEY_RIGHT);
    }

    public static boolean hasShiftDown() {
        return key(GLFW.GLFW_KEY_LEFT_SHIFT) || key(GLFW.GLFW_KEY_RIGHT_SHIFT);
    }

    public static boolean hasAltDown() {
        return key(GLFW.GLFW_KEY_LEFT_ALT) || key(GLFW.GLFW_KEY_RIGHT_ALT);
    }

    // --- Common edit shortcuts (global, no event required) --------------------

    public static boolean isSelectAllNow() {
        return key(GLFW.GLFW_KEY_A) && hasControlDown() && !hasShiftDown() && !hasAltDown();
    }

    public static boolean isCopyNow() {
        return key(GLFW.GLFW_KEY_C) && hasControlDown() && !hasShiftDown() && !hasAltDown();
    }

    public static boolean isPasteNow() {
        return key(GLFW.GLFW_KEY_V) && hasControlDown() && !hasShiftDown() && !hasAltDown();
    }

    public static boolean isCutNow() {
        return key(GLFW.GLFW_KEY_X) && hasControlDown() && !hasShiftDown() && !hasAltDown();
    }
    
    public static boolean isAnythingNow() {
    	return isSelectAllNow() || isCopyNow() || isPasteNow() || isCutNow();
    }

}
