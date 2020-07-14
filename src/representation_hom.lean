import representation
import ring_theory.algebra
import algebra.module

variables (G : Type*) [group G] (𝕜 : Type*) [field 𝕜]
variables (V : Type*) [add_comm_group V] [has_scalar G V] [vector_space 𝕜 V]
variables (W : Type*) [add_comm_group W] [has_scalar G W] [vector_space 𝕜 W]

variables [rep G 𝕜 V] [rep G 𝕜 W]

variables (V' : subrep G 𝕜 V) (W' : subrep G 𝕜 W)

structure hom :=
(to_fun : V → W)
(equiv : ∀ g : G, ∀ v : V, to_fun (g • v) = g • to_fun v)
(scalar : ∀ k : 𝕜, ∀ v : V, to_fun (k • v) = k • to_fun v)
(additive : ∀ v w : V, to_fun (v + w) = to_fun v + to_fun w)

instance : has_coe_to_fun (hom G 𝕜 V W) := ⟨_, λ m, m.to_fun⟩

lemma to_fun_eq_coe (φ : hom G 𝕜 V W) : φ.to_fun = φ := rfl

lemma hom_zero (φ : hom G 𝕜 V W) : φ 0 = 0 :=
begin
    have h := hom.additive φ 0 0,
    rw add_zero at h,
    rw ←to_fun_eq_coe,
    rw add_left_eq_self.1 h.symm,
end

@[ext] theorem ext (φ ψ : hom G 𝕜 V W) (h : ∀ v, φ v = ψ v) : φ = ψ :=
by cases φ; cases ψ; congr'; exact funext h

theorem ext_iff (φ ψ : hom G 𝕜 V W) : φ = ψ ↔ ∀ v, φ v = ψ v :=
⟨by { rintro rfl v, refl } , ext G 𝕜 V W φ ψ⟩

instance : add_comm_group (hom G 𝕜 V W) := {
    add := λ φ ψ, ⟨λ v, (φ v) + (ψ v),
    begin
        intros g v,
        rw group_module.distrib,
        rw ←to_fun_eq_coe,
        rw hom.equiv,
        rw ←to_fun_eq_coe,
        rw hom.equiv,
    end,
    begin
        intros k v,
        rw smul_add,
        rw ←to_fun_eq_coe,
        rw hom.scalar,
        rw ←to_fun_eq_coe,
        rw hom.scalar,
    end,
    begin
        intros v w,
        rw ←to_fun_eq_coe,
        rw ←to_fun_eq_coe,
        rw hom.additive,
        rw hom.additive,
        abel,
    end⟩,
    add_assoc :=
    begin
        intros φ ψ χ,
        rw ext_iff,
        intro v,
        change φ v + ψ v + χ v = φ v + (ψ v + χ v),
        rw add_assoc,
    end,
    zero := ⟨λ v, 0,
    begin
        intros g v,
        rw act_zero,
    end,
    begin
        intros k v,
        rw smul_zero,
    end,
    begin
        intros v w,
        rw zero_add,
    end⟩,
    zero_add :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        change 0 + φ v = φ v,
        rw zero_add,
    end,
    add_zero :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        change φ v + 0 = φ v,
        rw add_zero,
    end,
    neg := λ φ, ⟨λ v, - φ v,
    begin
        intros g v,
        rw ←to_fun_eq_coe,
        rw hom.equiv,
        rw act_neg,
    end,
    begin
        intros k v,
        rw ←to_fun_eq_coe,
        rw hom.scalar,
        rw smul_neg,
    end,
    begin
        intros v w,
        rw ←to_fun_eq_coe,
        rw hom.additive,
        rw neg_add,
    end⟩,
    add_left_neg :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        change -φ v + φ v = 0,
        rw add_left_neg,
    end,
    add_comm :=
    begin
        intros φ ψ,
        rw ext_iff,
        intro v,
        change φ v + ψ v = ψ v + φ v,
        rw add_comm,
    end
}

instance : module 𝕜 (hom G 𝕜 V W) := {
    smul := λ k, λ φ, ⟨λ v, k • φ v,
    begin
        intros g v,
        rw ←to_fun_eq_coe,
        rw hom.equiv,
        rw rep.linear,
    end,
    begin
        intros k v,
        rw ←to_fun_eq_coe,
        rw hom.scalar,
        rw smul_comm,
    end,
    begin
        intros v w,
        rw ←to_fun_eq_coe,
        rw hom.additive,
        rw smul_add,
    end⟩,
    one_smul :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        change (1 : 𝕜) • φ v = φ v,
        rw one_smul,
    end,
    mul_smul :=
    begin
        intros k l φ,
        rw ext_iff,
        intro v,
        change (k * l) • φ v = k • l • φ v,
        rw mul_smul,
    end,
    smul_add :=
    begin
        intros k φ ψ,
        rw ext_iff,
        intro v,
        change k • (φ v + ψ v) = k • φ v + k • ψ v,
        rw smul_add,
    end,
    smul_zero :=
    begin
        intro k,
        rw ext_iff,
        intro v,
        change k • (0 : W) = 0,
        rw smul_zero,
    end,
    add_smul :=
    begin
        intros k l φ,
        rw ext_iff,
        intro v,
        change (k + l) • φ v = k • φ v + l • φ v,
        rw add_smul,
    end,
    zero_smul :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        change (0 : 𝕜) • φ v = 0,
        rw zero_smul,
    end
}

instance : semiring (hom G 𝕜 V V) := {
    add := add_comm_group.add,
    add_assoc := add_comm_group.add_assoc,
    zero := add_comm_group.zero,
    zero_add := add_comm_group.zero_add,
    add_zero := add_comm_group.add_zero,
    add_comm := add_comm_group.add_comm,
    mul := λ φ ψ, ⟨λ v, φ (ψ v),
    begin
        intros g v,
        rw ←to_fun_eq_coe,
        rw ←to_fun_eq_coe,
        rw hom.equiv,
        rw hom.equiv,
    end,
    begin
        intros k v,
        rw ←to_fun_eq_coe,
        rw ←to_fun_eq_coe,
        rw hom.scalar,
        rw hom.scalar,
    end,
    begin
        intros v w,
        rw ←to_fun_eq_coe,
        rw ←to_fun_eq_coe,
        rw hom.additive,
        rw hom.additive,
    end⟩,
    mul_assoc :=
    begin
        intros φ ψ χ,
        rw ext_iff,
        intro v,
        refl,
    end,
    one := ⟨λ v, v,
    begin
        intros g v,
        refl,
    end,
    begin
        intros g k,
        refl,
    end,
    begin
        intros v w,
        refl,
    end⟩,
    one_mul :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        refl,
    end,
    mul_one :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        refl,
    end,
    left_distrib :=
    begin
        intros φ ψ χ,
        rw ext_iff,
        intro v,
        change φ (ψ v + χ v) = φ (ψ v) + φ (χ v),
        rw ←to_fun_eq_coe,
        rw hom.additive,
    end,
    right_distrib :=
    begin
        intros φ ψ χ,
        rw ext_iff,
        intro v,
        refl,
    end,
    zero_mul :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        refl,
    end,
    mul_zero :=
    begin
        intro φ,
        rw ext_iff,
        intro v,
        change φ 0 = 0,
        rw hom_zero,
    end,
}

instance : algebra 𝕜 (hom G 𝕜 V V) := {
    to_fun := λ k, k • 1,
    map_one' :=
    begin
        rw one_smul,
    end,
    map_mul' :=
    begin
        intros k l,
        rw ext_iff,
        intro v,
        rw mul_smul,
        refl,
    end,
    map_zero' :=
    begin
        rw ext_iff,
        intro v,
        rw zero_smul,
    end,
    map_add' :=
    begin
        intros k l,
        rw ext_iff,
        intro v,
        rw add_smul,
    end,
    commutes' :=
    begin
        intros k φ,
        rw ext_iff,
        intro v,
        change k • φ v = φ (k • v),
        rw ←to_fun_eq_coe,
        rw hom.scalar,
    end,
    smul_def' :=
    begin
        intros k φ,
        rw ext_iff,
        intro v,
        refl,
    end
}

--basic version of schur's lemma
--todo: maybe make separate definitions for isomorphism and for the zero map
--todo: prove this theorem (it might require classical logic?)

theorem irred_thm (irred_V : irreducible G 𝕜 V) (irred_W : irreducible G 𝕜 W) (φ : hom G 𝕜 V W) :
(φ = 0) ∨ ((∀ w, ∃ v, φ v = w) ∧ (∀ v, φ v = 0 → v = 0)) :=
begin
    sorry
end