package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.lang.Math.*;

public class TestHoursBean implements Serializable {
	private int hours = 0;
	public int getHours() { return hours; }
	public void setHours(int hours) { this.hours = hours; }
	private boolean TestH(double pw) {
		boolean isValid = false;
		int power = Double.valueOf(Math.pow(2,pw)).intValue();
		if ((hours & power) == power) { isValid = true; }
		return isValid;
	}
	public boolean isHour0() { return TestH(0); }
	public boolean isHour1() { return TestH(1); }
	public boolean isHour2() { return TestH(2); }
	public boolean isHour3() { return TestH(3); }
	public boolean isHour4() { return TestH(4); }
	public boolean isHour5() { return TestH(5); }
	public boolean isHour6() { return TestH(6); }
	public boolean isHour7() { return TestH(7); }
	public boolean isHour8() { return TestH(8); }
	public boolean isHour9() { return TestH(9); }
	public boolean isHour10() { return TestH(10); }
	public boolean isHour11() { return TestH(11); }
	public boolean isHour12() { return TestH(12); }
	public boolean isHour13() { return TestH(13); }
	public boolean isHour14() { return TestH(14); }
	public boolean isHour15() { return TestH(15); }
	public boolean isHour16() { return TestH(16); }
	public boolean isHour17() { return TestH(17); }
	public boolean isHour18() { return TestH(18); }
	public boolean isHour19() { return TestH(19); }
	public boolean isHour20() { return TestH(20); }
	public boolean isHour21() { return TestH(21); }
	public boolean isHour22() { return TestH(22); }
	public boolean isHour23() { return TestH(23); }
	public boolean isHour(double h) { return TestH(h); }
}
