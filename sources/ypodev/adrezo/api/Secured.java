package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import javax.ws.rs.*;
import java.lang.annotation.*;

@NameBinding
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.TYPE})
public @interface Secured {
	Role[] value() default {};
}

