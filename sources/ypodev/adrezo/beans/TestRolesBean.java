package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;

public class TestRolesBean implements Serializable {
	private int roles = 0;
	public int getRoles() { return roles; }
	public void setRoles(int roles) { this.roles = roles; }
	public boolean isIp() {
		boolean isValid = false;
		if ((roles & 1) == 1) { isValid = true; }
		return isValid;
	}
	public boolean isPhoto() {
		boolean isValid = false;
		if ((roles & 2) == 2) { isValid = true; }
		return isValid;
	}
	public boolean isStock() {
		boolean isValid = false;
		if ((roles & 4) == 4) { isValid = true; }
		return isValid;
	}
	public boolean isStockAdmin() {
		boolean isValid = false;
		if ((roles & 8) == 8) { isValid = true; }
		return isValid;
	}
	public boolean isAdmin() {
		boolean isValid = false;
		if ((roles & 16) == 16) { isValid = true; }
		return isValid;
	}
	public boolean isRezo() {
		boolean isValid = false;
		if ((roles & 32) == 32) { isValid = true; }
		return isValid;
	}
	public boolean isApi() {
		boolean isValid = false;
		if ((roles & 64) == 64) { isValid = true; }
		return isValid;
	}
	public boolean isTemplate() {
		boolean isValid = false;
		if ((roles & 128) == 128) { isValid = true; }
		return isValid;
	}
}
