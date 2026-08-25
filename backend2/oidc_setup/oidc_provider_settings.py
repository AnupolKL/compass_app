"""
OIDC Provider settings — userinfo callback and scope claims.
Referenced in backend2/settings.py via OIDC_USERINFO and OIDC_EXTRA_SCOPE_CLAIMS.
"""

from oidc_provider.lib.claims import ScopeClaims


def userinfo(claims, user):
    """Populate OIDC claims from Django user model."""
    claims["name"] = user.get_full_name() or user.username
    claims["given_name"] = user.first_name
    claims["family_name"] = user.last_name
    claims["email"] = user.email
    claims["preferred_username"] = user.username
    return claims


class CustomScopeClaims(ScopeClaims):
    """Custom scope claims — extend as needed."""
    pass
