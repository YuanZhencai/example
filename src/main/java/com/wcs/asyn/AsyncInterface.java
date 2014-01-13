package com.wcs.asyn;

import java.util.concurrent.Future;

public interface AsyncInterface {
	Future<String> sendMessages(String message);
}
