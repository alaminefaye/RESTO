<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class MenuController extends Controller
{
    // ========== CATEGORIES ==========
    
    public function categoriesIndex()
    {
        $categories = Category::withCount('produits')->get();
        return view('menu.categories.index', compact('categories'));
    }
    
    public function categoriesCreate()
    {
        return view('menu.categories.create');
    }
    
    public function categoriesStore(Request $request)
    {
        $validated = $request->validate([
            'nom' => 'required|string|max:255|unique:categories,nom',
            'description' => 'nullable|string',
            'ordre' => 'nullable|integer|min:0',
        ]);
        
        $validated['actif'] = $request->has('actif');
        
        Category::create($validated);
        
        return redirect()->route('menu.categories.index')
                        ->with('success', 'Catégorie créée avec succès !');
    }
    
    public function categoriesEdit(Category $category)
    {
        return view('menu.categories.edit', compact('category'));
    }
    
    public function categoriesUpdate(Request $request, Category $category)
    {
        $validated = $request->validate([
            'nom' => ['required', 'string', 'max:255', Rule::unique('categories')->ignore($category->id)],
            'description' => 'nullable|string',
            'ordre' => 'nullable|integer|min:0',
        ]);
        
        $validated['actif'] = $request->has('actif');
        
        $category->update($validated);
        
        return redirect()->route('menu.categories.index')
                        ->with('success', 'Catégorie modifiée avec succès !');
    }
    
    public function categoriesDestroy(Category $category)
    {
        $category->delete();
        return redirect()->route('menu.categories.index')
                        ->with('success', 'Catégorie supprimée avec succès !');
    }
    
    // ========== PRODUCTS ==========
    
    public function productsIndex()
    {
        $products = Product::with('categorie')->get();
        $categories = Category::all();
        return view('menu.products.index', compact('products', 'categories'));
    }
    
    public function productsCreate()
    {
        $categories = Category::where('actif', true)->get();
        return view('menu.products.create', compact('categories'));
    }
    
    public function productsStore(Request $request)
    {
        $validated = $request->validate([
            'categorie_id' => 'required|exists:categories,id',
            'nom' => 'required|string|max:255',
            'description' => 'nullable|string',
            'prix' => 'required|numeric|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);
        
        $validated['disponible'] = $request->has('disponible');
        $validated['actif'] = $request->has('actif');
        
        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('public/produits');
        }
        
        Product::create($validated);
        
        return redirect()->route('menu.products.index')
                        ->with('success', 'Produit créé avec succès !');
    }
    
    public function productsEdit(Product $product)
    {
        $categories = Category::all();
        return view('menu.products.edit', compact('product', 'categories'));
    }
    
    public function productsUpdate(Request $request, Product $product)
    {
        $validated = $request->validate([
            'categorie_id' => 'required|exists:categories,id',
            'nom' => 'required|string|max:255',
            'description' => 'nullable|string',
            'prix' => 'required|numeric|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);
        
        $validated['disponible'] = $request->has('disponible');
        $validated['actif'] = $request->has('actif');
        
        if ($request->hasFile('image')) {
            // Delete old image
            if ($product->image) {
                Storage::delete($product->image);
            }
            $validated['image'] = $request->file('image')->store('public/produits');
        }
        
        $product->update($validated);
        
        return redirect()->route('menu.products.index')
                        ->with('success', 'Produit modifié avec succès !');
    }
    
    public function productsDestroy(Product $product)
    {
        // Delete image
        if ($product->image) {
            Storage::delete($product->image);
        }
        
        $product->delete();
        
        return redirect()->route('menu.products.index')
                        ->with('success', 'Produit supprimé avec succès !');
    }
    
    public function toggleAvailability(Product $product)
    {
        $product->is_available = !$product->is_available;
        $product->save();
        
        return back()->with('success', 'Disponibilité modifiée avec succès !');
    }
}
