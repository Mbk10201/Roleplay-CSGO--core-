#if defined _collisionhook_included
 #endinput
#endif
#define _collisionhook_included

enum CollisionHookResult
{
	Result_Ignore, 	// Plugin didn't take any action, let's the game decide
	Result_Block,	// Block the hook.
	Result_Allow	// Allow the hook to go through.
}

/**
 * Called when the game is performing VPhysics collision checks between two entities.
 * 
 * @param ent1		First entity index.
 * @param ent2		Second entity index.
 * @param result	CollisionHookResult value.
 */
forward void CH_ShouldCollide(int ent1, int ent2, CollisionHookResult &result);

/**
 * Called when the game performs collision checks through trace filters.
 *
 * Note that you should avoid doing expensive computations or declaring large local arrays.
 * 
 * @param ent1		First entity index.
 * @param ent2		Second entity index.
 * @param result	CollisionHookResult value.
 */
forward void CH_PassFilter(int ent1, int ent2, CollisionHookResult &result);

/**
 * Do not edit below this line!
 */
public Extension __ext_collisionhook = 
{
	name = "collisionhook",
	file = "collisionhook.ext",
#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};