package ypodev.adrezo.util;

/*
 * @Author : Yann POSTEC
 */
 
import java.util.*;

public class IPFmt {
	public static String TrimLZero(String mys) {
		if (mys.length()>1 && mys.substring(0,1).equals("0")) { return TrimLZero(mys.substring(1,mys.length())); }
		else { return mys; }
	}
	
	public static String displayIP(String mys) {
		if (mys != null && mys.length() == 12) {
			return TrimLZero(mys.substring(0,3)) + "." + TrimLZero(mys.substring(3,6)) + "." + TrimLZero(mys.substring(6,9)) + "." + TrimLZero(mys.substring(9,12));
		}
		else { return mys; }
	}
	
	public static String displayMask(String mymask) {
		String res = "undefined";
		if (mymask != null && !mymask.equals("")) {
			int mask = Integer.parseInt((String)mymask);
			switch (mask) {
				case 2: res="192.0.0.0";break;
				case 3: res="224.0.0.0";break;
				case 4: res="240.0.0.0";break;
				case 5: res="248.0.0.0";break;
				case 6: res="252.0.0.0";break;
				case 7: res="254.0.0.0";break;
				case 8: res="255.0.0.0";break;
				case 9: res="255.128.0.0";break;
				case 10: res="255.192.0.0";break;
				case 11: res="255.224.0.0";break;
				case 12: res="255.240.0.0";break;
				case 13: res="255.248.0.0";break;
				case 14: res="255.252.0.0";break;
				case 15: res="255.254.0.0";break;
				case 16: res="255.255.0.0";break;
				case 17: res="255.255.128.0";break;
				case 18: res="255.255.192.0";break;
				case 19: res="255.255.224.0";break;
				case 20: res="255.255.240.0";break;
				case 21: res="255.255.248.0";break;
				case 22: res="255.255.252.0";break;
				case 23: res="255.255.254.0";break;
				case 24: res="255.255.255.0";break;
				case 25: res="255.255.255.128";break;
				case 26: res="255.255.255.192";break;
				case 27: res="255.255.255.224";break;
				case 28: res="255.255.255.240";break;
				case 29: res="255.255.255.248";break;
				case 30: res="255.255.255.252";break;
				case 31: res="255.255.255.254";break;
				case 32: res="255.255.255.255";break;
				default: res="undef";
			}
		}
		return res;
	}	
	
	public static String maskBits(String mymask) {
		String res = "undefined";
		if (mymask != null && !mymask.equals("")) {
			int mask = Integer.parseInt((String)mymask);
			switch (mask) {
				case 2: res="192000000000";break;
				case 3: res="224000000000";break;
				case 4: res="240000000000";break;
				case 5: res="248000000000";break;
				case 6: res="252000000000";break;
				case 7: res="254000000000";break;
				case 8: res="255000000000";break;
				case 9: res="255128000000";break;
				case 10: res="255192000000";break;
				case 11: res="255224000000";break;
				case 12: res="255240000000";break;
				case 13: res="255248000000";break;
				case 14: res="255252000000";break;
				case 15: res="255254000000";break;
				case 16: res="255255000000";break;
				case 17: res="255255128000";break;
				case 18: res="255255192000";break;
				case 19: res="255255224000";break;
				case 20: res="255255240000";break;
				case 21: res="255255248000";break;
				case 22: res="255255252000";break;
				case 23: res="255255254000";break;
				case 24: res="255255255000";break;
				case 25: res="255255255128";break;
				case 26: res="255255255192";break;
				case 27: res="255255255224";break;
				case 28: res="255255255240";break;
				case 29: res="255255255248";break;
				case 30: res="255255255252";break;
				case 31: res="255255255254";break;
				case 32: res="255255255255";break;
				default: res="undef";
			}
		}
		return res;
	}	
	
	public static boolean in_subnet(String ip, String ipsub, String masksub) {
		String mask = maskBits(masksub);
		if (ip.length() == 12) {
			int a = Integer.parseInt((String)ip.substring(0,3)) & Integer.parseInt((String)mask.substring(0,3));
			int b = Integer.parseInt((String)ip.substring(3,6)) & Integer.parseInt((String)mask.substring(3,6));
			int c = Integer.parseInt((String)ip.substring(6,9)) & Integer.parseInt((String)mask.substring(6,9));
			int d = Integer.parseInt((String)ip.substring(9,12)) & Integer.parseInt((String)mask.substring(9,12));
			if (ipsub.compareTo(AddLZeroToInt(a) + AddLZeroToInt(b) + AddLZeroToInt(c) + AddLZeroToInt(d)) == 0) { return true; } else { return false; }
		} else { return false; }
	}
	
	public static String GetBroadcast(String ipsub, String masksub) {
		String res = "";
		String mask = maskBits(masksub);
		if (ipsub.length() == 12) {
			int a = Integer.parseInt((String)ipsub.substring(0,3)) + 255 - Integer.parseInt((String)mask.substring(0,3));
			int b = Integer.parseInt((String)ipsub.substring(3,6)) + 255 - Integer.parseInt((String)mask.substring(3,6));
			int c = Integer.parseInt((String)ipsub.substring(6,9)) + 255 - Integer.parseInt((String)mask.substring(6,9));
			int d = Integer.parseInt((String)ipsub.substring(9,12)) + 255 - Integer.parseInt((String)mask.substring(9,12));
			res = AddLZeroToInt(a) + AddLZeroToInt(b) + AddLZeroToInt(c) + AddLZeroToInt(d);
		}
		return res;
	}
	
	public static String GetNetwork(String ip, String masksub) {
		String res = "";
		String mask = maskBits(masksub);
		if (ip.length() == 12) {
			int a = Integer.parseInt((String)ip.substring(0,3)) & Integer.parseInt((String)mask.substring(0,3));
			int b = Integer.parseInt((String)ip.substring(3,6)) & Integer.parseInt((String)mask.substring(3,6));
			int c = Integer.parseInt((String)ip.substring(6,9)) & Integer.parseInt((String)mask.substring(6,9));
			int d = Integer.parseInt((String)ip.substring(9,12)) & Integer.parseInt((String)mask.substring(9,12));
			res = AddLZeroToInt(a) + AddLZeroToInt(b) + AddLZeroToInt(c) + AddLZeroToInt(d);
		}
		return res;
	}
	
	public static Vector<String> SplitSubnet(String ipsub, String masksub, String newmask) {
		Vector<String> res = new Vector<String>();
		String initmask = maskBits(masksub);
		String splitmask = maskBits(newmask);
		if (ipsub.length() == 12 && Integer.parseInt((String)masksub)<Integer.parseInt((String)newmask)) {
			int a = Integer.parseInt((String)splitmask.substring(0,3)) - Integer.parseInt((String)initmask.substring(0,3));
			int b = Integer.parseInt((String)splitmask.substring(3,6)) - Integer.parseInt((String)initmask.substring(3,6));
			int c = Integer.parseInt((String)splitmask.substring(6,9)) - Integer.parseInt((String)initmask.substring(6,9));
			int d = Integer.parseInt((String)splitmask.substring(9,12)) - Integer.parseInt((String)initmask.substring(9,12));
			int ipa = Integer.parseInt((String)ipsub.substring(0,3));
			int ipb = Integer.parseInt((String)ipsub.substring(3,6));
			int ipc = Integer.parseInt((String)ipsub.substring(6,9));
			int ipd = Integer.parseInt((String)ipsub.substring(9,12));
			int na = 256 - Integer.parseInt((String)splitmask.substring(0,3));
			int nb = 256 - Integer.parseInt((String)splitmask.substring(3,6));
			int nc = 256 - Integer.parseInt((String)splitmask.substring(6,9));
			int nd = 256 - Integer.parseInt((String)splitmask.substring(9,12));
			for (int i=ipa;i<ipa+a+1;i=i+na) {
				for (int j=ipb;j<ipb+b+1;j=j+nb) {
					for (int k=ipc;k<ipc+c+1;k=k+nc) {
						for (int l=ipd;l<ipd+d+1;l=l+nd) {
							res.add(AddLZeroToInt(i) + AddLZeroToInt(j) + AddLZeroToInt(k) + AddLZeroToInt(l));
						}
					}
				}
			}
		}
		return res;
	}
	
	public static String AddLZeroToInt(int myint) {
		if (myint < 10 ) { return "00" + Integer.toString(myint); }
		else if (myint <100) { return "0" + Integer.toString(myint); }
			else {return Integer.toString(myint); }
	}
	
	public static String incIP(String myip) {
		int a = Integer.parseInt((String)myip.substring(0,3));
		int b = Integer.parseInt((String)myip.substring(3,6));
		int c = Integer.parseInt((String)myip.substring(6,9));
		int d = Integer.parseInt((String)myip.substring(9,12));
		if (d<255) { d++; }
		else {
			d=0;
			if (c<255) { c++; }
			else {
				c=0;
				if (b<255) { b++; }
				else {
					b=0;
					a++;
				}
			}
		}
		return AddLZeroToInt(a) + AddLZeroToInt(b) + AddLZeroToInt(c) + AddLZeroToInt(d);
	}
	
	public static Vector<String> VectorIP(String start,String end) {
		start=incIP(start);
		Vector<String> res = new Vector<String>();
		while (start.compareTo(end) <0) {
			res.add(start);
			start=incIP(start);
	 	}
	 	return res;
	}
	
	public static String renderIP(String myip) {
		String res="";
		if (myip!=null) {
			String[] partip = myip.split("\\.",-1);
			for (String p: partip) { res += AddLZeroToInt(Integer.parseInt(p)); }
		}
		return(res);
	}
	
	public static boolean verifIP(String myip) {
		boolean res=true;
		if (myip!=null && myip.length()<17) {
			String[] partip = myip.split("\\.",-1);
			if (partip.length==4) {
				for (String p: partip) {
					try {
						int check = Integer.parseInt(p);
						if (check < 0 || check > 256) { res=false; }
					}
					catch (NumberFormatException e) { res=false; }
				}
			} else { res=false; }
		} else { res=false; }
		return res;
	}
	
	public static String addTwoIP(String ip1, String ip2) {
		if (ip1 == null || ip1.equals("") || ip2 == null || ip2.equals("")) {
			return "";
		} else {
			int a1 = Integer.parseInt((String)ip1.substring(0,3));
			int b1 = Integer.parseInt((String)ip1.substring(3,6));
			int c1 = Integer.parseInt((String)ip1.substring(6,9));
			int d1 = Integer.parseInt((String)ip1.substring(9,12));
			int a2 = Integer.parseInt((String)ip2.substring(0,3));
			int b2 = Integer.parseInt((String)ip2.substring(3,6));
			int c2 = Integer.parseInt((String)ip2.substring(6,9));
			int d2 = Integer.parseInt((String)ip2.substring(9,12));
			return AddLZeroToInt(a1+a2) + AddLZeroToInt(b1+b2) + AddLZeroToInt(c1+c2) + AddLZeroToInt(d1+d2);
		}
	}
}
